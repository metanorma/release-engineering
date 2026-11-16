#!/usr/bin/env ruby
# frozen_string_literal: true

# Ribose-managed gem version ledger for a release wave.
#
# Usage: gem-ledger.rb <prev-docker-tag> <wave-docker-tag> [owner/repo]
#
# Fetches metanorma-debian/Gemfile.lock from both metanorma-docker tags,
# diffs the versions of every Ribose-managed gem (per GEM-OWNERSHIP.md),
# and prints the wave-issue ledger as markdown:
#   - a summary (changes, additions, removals, unchanged count)
#   - a "Changed in this wave" table first (gem | org | version),
#     new gems highlighted, dropped gems struck through
#   - everything unchanged collapsed behind a <details> dropdown,
#     expanded as per-org tables
#   - gems absent from both bundles fall back to their rubygems version
#
# Example: gem-ledger.rb v1.18.5 v1.18.6

require "net/http"
require "json"

TAG1 = ARGV[0] or abort "usage: gem-ledger.rb <prev-tag> <wave-tag> [owner/repo]"
TAG2 = ARGV[1] or abort "usage: gem-ledger.rb <prev-tag> <wave-tag> [owner/repo]"
REPO = ARGV[2] || "metanorma/metanorma-docker"
LOCK = "metanorma-debian/Gemfile.lock"

def norm(tag) = tag.start_with?("v") ? tag : "v#{tag}"

def fetch_lock(tag)
  uri = URI("https://raw.githubusercontent.com/#{REPO}/#{norm(tag)}/#{LOCK}")
  res = Net::HTTP.get_response(uri)
  abort "cannot fetch #{uri} (HTTP #{res.code})" unless res.is_a?(Net::HTTPSuccess)
  res.body
end

def parse_versions(lock_body)
  lock_body.scan(/^    ([a-zA-Z0-9_.-]+) \(([^\s()]+)\)$/).to_h
end

def rubygems_version(gem)
  uri = URI("https://rubygems.org/api/v1/gems/#{gem}.json")
  JSON.parse(Net::HTTP.get(uri))["version"]
rescue StandardError
  "?"
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

old = parse_versions(fetch_lock(TAG1))
new = parse_versions(fetch_lock(TAG2))

changed = []   # [org, gem, version-cell, kind(:new/:removed/:changed)]
unchanged = Hash.new { |h, k| h[k] = [] }

manifest.each do |org, gems|
  gems.each do |g|
    o = old[g]
    v = new[g]
    if o && v && o != v
      changed << [org, g, "`#{o}` → `#{v}`", :changed]
    elsif o.nil? && v
      changed << [org, g, "`#{v}` — **new in this wave**", :new]
    elsif v.nil? && o
      changed << [org, g, "~~`#{o}`~~ — removed from the bundle", :removed]
    else
      v ||= "#{rubygems_version(g)} (not in bundle)"
      unchanged[org] << "| `#{g}` | `#{v}` |"
    end
  end
end

order = { new: 0, removed: 1, changed: 2 }
changed.sort_by! { |_org, g, _cell, kind| [order[kind], g] }

added_names = changed.select { |r| r[3] == :new }.map { |_o, g, _c, _k| "#{g} #{new[g]}" }
removed_names = changed.select { |r| r[3] == :removed }.map { |_o, g, _c, _k| g }
n_unchanged = unchanged.values.sum(&:size)

out = [
  "### Ribose-managed gem versions — #{norm(TAG2).delete_prefix('v')} wave",
  "",
  "Resolved versions of every Ribose-managed gem (per `GEM-OWNERSHIP.md`) in the shipped state, from the frozen bundle (`#{LOCK}` at the `#{REPO}` #{norm(TAG2)} tag), **diffed against the previous wave's frozen bundle (#{norm(TAG1)})**:",
  "",
  "- **#{changed.count { |r| r[3] == :changed }} version changes** carried into this wave",
  "- **#{changed.count { |r| r[3] == :new }} gems newly added** to the bundle#{added_names.empty? ? '' : ': ' + added_names.join(', ')}",
  "- **#{changed.count { |r| r[3] == :removed }} gems removed**#{removed_names.empty? ? '' : ': ' + removed_names.join(', ')}",
  "- **#{n_unchanged} gems unchanged** (collapsed below)",
  "",
  "The full lock remains the reference for external gems.",
  "",
  "### Changed in this wave",
  "",
  "| gem | org | version |",
  "|---|---|---|",
]
changed.each do |org, g, cell, _kind|
  out << "| `#{g}` | #{org} | #{cell} |"
end

unless n_unchanged.zero?
  out << ""
  out << "<details>"
  out << "<summary>Unchanged — #{n_unchanged} gems (expanded by org)</summary>"
  unchanged.each do |org, rows|
    out << ""
    out << "**#{org}** (#{rows.size})"
    out << ""
    out << "| gem | version |"
    out << "|---|---|"
    out.concat(rows)
  end
  out << ""
  out << "</details>"
end

puts out.join("\n")
