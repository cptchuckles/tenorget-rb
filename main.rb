#!/usr/bin/env ruby
# frozen_string_literal: true

require 'uri'
require 'open-uri'
require 'net/http'
require 'nokogiri'

require './wget'

destdir = File.join(Dir.home, 'pictures', 'tenor')

while (arg = ARGV.shift)
  case arg
  when '-d' || '--dest'
    destdir = ARGV.shift
  when '--'
    break
  else
    ARGV.push(arg)
    break
  end
end

Dir.mkdir(destdir) unless Dir.exist?(destdir)

ARGF.read.lines.each do |line|
  url = URI.parse(line.chomp)

  res = Net::HTTP.get_response(url)

  code = res.code.to_i
  if code < 200 || 300 <= code
    warn "ERROR - received #{code} for #{line.chomp}"
    next
  end

  doc = Nokogiri::HTML5.parse(res.body)

  sources = doc.css('meta[property="og:video"]')
               .filter_map { |meta| meta.attributes['content'].value }

  formats = %w[webm mkv mp4 avi]
  best_source = sources.min_by { |s| formats.index { |ext| s.end_with?(ext) } || formats.count }

  ext = File.extname(best_source)
  filename = "#{File.basename(best_source, ext)}-#{best_source.split('/')[-2]}#{ext}"
  destfile = File.join(destdir, filename)

  if File.exist?(destfile)
    warn "#{destfile} exists already. Skipping download of #{best_source}"
    next
  end

  puts "Downloading #{best_source} to #{destfile}..."

  wget(best_source, destfile)
end
