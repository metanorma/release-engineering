#!/usr/bin/env ruby
# frozen_string_literal: true

# Per-gem changelog + wave summary for a release wave.
#
# Usage: gem-changelog.rb <prev-tag> <wave-tag> [docker owner/repo]
#
# For every Ribose-managed gem whose version changed between the two
# metanorma-docker tags (per GEM-OWNERSHIP.md org grouping), extracts what
# changed: the GitHub Release notes for the new version when they exist,
# otherwise the commit subjects from the two tags' compare. Prints markdown
# for the wave issue:
#
#   ### Wave summary          — totals + busiest gems (mechanical)
#   ### Per-gem changelog     — per-org groups, capped lines per gem
#
# Auth: GITHUB_TOKEN or `gh auth token` (the compare/release API is
# rate-limited without a token).

require "net/http"
require "json"

TAG1 = ARGV[0] or abort "usage: gem-changelog.rb <prev-tag> <wave-tag> [docker owner/repo]"
TAG2 = ARGV[1] or abort "usage: gem-changelog.rb <prev-tag> <wave-tag> [docker owner/repo]"
LOCK_REPO = ARGV[2] || "metanorma/metanorma-docker"
LOCK = "metanorma-debian/Gemfile.lock"
CAP = 8

TOKEN = [ENV["GITHUB_TOKEN"], `gh auth token 2>/dev/null`.chomp].find { |t| t && !t.empty? }

def norm(tag) = tag.start_with?("v") ? tag : "v#{tag}"

def api(path)
  uri = URI("https://api.github.com/#{path}")
  req = Net::HTTP::Get.new(uri)
  req["Accept"] = "application/vnd.github+json"
  req["Authorization"] = "Bearer #{TOKEN}" if TOKEN
  Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
end

def get_json(path)
  res = api(path)
  if res.code == "403" && res["X-RateLimit-Remaining"] == "0"
    abort "GitHub rate limit exhausted; set GITHUB_TOKEN or `gh auth login`"
  end
  return nil if res.code == "404"
  abort "GitHub API #{res.code} on #{path}: #{res.body[0, 200]}" unless res.code.start_with?("2")
  JSON.parse(res.body)
end

def lock_versions(tag)
  uri = URI("https://raw.githubusercontent.com/#{LOCK_REPO}/#{norm(tag)}/#{LOCK}")
  res = Net::HTTP.get_response(uri)
  abort "cannot fetch #{uri} (HTTP #{res.code})" unless res.is_a?(Net::HTTPSuccess)
  res.body.scan(/^    ([a-zA-Z0-9_.-]+) \(([^\s()]+)\)$/).to_h
end

def manifest
  path = File.join(__dir__, "GEM-OWNERSHIP.md")
  orgs = {}
  cur = nil
  File.foreach(path) do |line|
    if (m = line.match(/^## (\S+) \(\d+ gems?\)/))
      cur = m[1]
      orgs[cur] = []
    elsif (m = line.match(/^- `([a-z0-9_-]+)`/)) && cur
      orgs[cur] << m[1]
    end
  end
  orgs
end

def source_repo(gem, org)
  u = JSON.parse(Net::HTTP.get(URI("https://rubygems.org/api/v1/gems/#{gem}.json")))
  src = u["source_code_uri"] || u["homepage_uri"] || ""
  m = src.match(%r{github\.com/([^/]+/[^/]+?)(?:\.git)?/?$})
  m ? m[1] : "#{org}/#{gem}"
rescue StandardError
  "#{org}/#{gem}"
end

def resolve_tag(repo, ver)
  %W[v#{ver} #{ver}].each do |t|
    return t if get_json("repos/#{repo}/git/ref/tags/#{t}")
  end
  nil
end

def release_bullets(repo, tag)
  rel = get_json("repos/#{repo}/releases/tags/#{tag}")
  return nil unless rel && rel["body"]
  bullets = rel["body"].split(/^## New Contributors/).first
                       .lines.select { |l| l.start_with?("* ") }
  bullets.empty? ? nil : bullets.map { |l| l.sub(/^\* /, "").strip }
end

def compare(repo, old_t, new_t)
  c = get_json("repos/#{repo}/compare/#{old_t}...#{new_t}")
  return nil unless c
  subjects = c["commits"].map { |cm| cm["commit"]["message"].lines.first.to_s.strip }
                         .reject { |s| s.start_with?("Merge ") }
  [c["total_commits"].to_i, subjects]
end

old = lock_versions(TAG1)
new = lock_versions(TAG2)

summary_rows = []
body = ["", "### Per-gem changelog", "",
        "Mechanical extraction (`gem-changelog.rb`): GitHub Release notes for the new version when present, otherwise commit subjects from the tags' compare; capped at #{CAP} lines per gem. Source links carry the full list.", ""]

manifest.each do |org, gems|
  org_rows = []
  gems.each do |g|
    o = old[g]
    v = new[g]
    next unless o && v && o != v

    repo = source_repo(g, org)
    new_t = resolve_tag(repo, v)
    old_t = resolve_tag(repo, o)
    if new_t.nil?
      org_rows << "#### `#{g}` `#{o}` → `#{v}` — **#{v} has no git tag on #{repo}** (gem shipped without its tag — release-hygiene gap)"
      summary_rows << [org, g, 0]
      next
    elsif old_t.nil?
      org_rows << "#### `#{g}` `#{o}` → `#{v}` — previous version #{o} not tagged on #{repo} — [releases](https://github.com/#{repo}/releases)"
      summary_rows << [org, g, 0]
      next
    end

    url = "https://github.com/#{repo}/compare/#{old_t}...#{new_t}"
    bullets = release_bullets(repo, new_t)
    if bullets
      org_rows << "#### `#{g}` `#{o}` → `#{v}` — #{bullets.size} change#{bullets.size == 1 ? '' : 's'} — [release notes](https://github.com/#{repo}/releases/tag/#{new_t})"
      org_rows.concat(bullets.first(CAP).map { |b| "- #{b}" })
      org_rows << "- …and #{bullets.size - CAP} more" if bullets.size > CAP
      summary_rows << [org, g, bullets.size, :release]
    else
      total, subjects = compare(repo, old_t, new_t)
      if total.nil?
        org_rows << "#### `#{g}` `#{o}` → `#{v}` — [compare](#{url}) — changelog unavailable"
        summary_rows << [org, g, 0]
        next
      end
      org_rows << "#### `#{g}` `#{o}` → `#{v}` — #{total} commit#{total == 1 ? '' : 's'} — [compare](#{url})"
      org_rows.concat(subjects.first(CAP).map { |s| "- #{s}" }) unless subjects.empty?
      org_rows << "- …and #{total - CAP} more" if total > CAP
      summary_rows << [org, g, total]
    end
  end
  next if org_rows.empty?
  body << "**#{org}**"
  body << ""
  body.concat(org_rows)
  body << ""
end

busy = summary_rows.sort_by { |r| -r[2] }.first(6)
total_commits = summary_rows.sum { |r| r[2] }
head = ["### Wave summary",
        "",
        "- **#{summary_rows.size} Ribose gems advanced** between #{norm(TAG1).delete_prefix('v')} and #{norm(TAG2).delete_prefix('v')}",
        "- **#{total_commits} changes** recorded across them (release-note bullets or commits, per gem)",
        "- busiest: #{busy.map { |_org, g, n, src| "`#{g}` (#{n}#{src == :release ? ' notes' : ''})" }.join(', ')}",
        "",
        "The ledger comment carries the version table; this comment carries the change descriptions. Add the wave narrative (one paragraph, close-out) above the mechanical summary when posting."]

puts (head + body).join("\n")
