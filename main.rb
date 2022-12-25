#!/usr/bin/env ruby
# frozen_string_literal: true

require 'uri'
require 'open-uri'
require 'net/http'
require 'nokogiri'

require './wget'

destdir = (ENV['XDG_HOME'] || ENV['HOME']) + '/pictures/tenor'

while (arg = ARGV.shift)
  case arg
  when '-d' || '--dest'
    destdir = ARGV.shift
  when '--'
    break
  else
    ARGV.push arg
    break
  end
end

Dir.mkdir(destdir) unless Dir.exist? destdir

ARGF.read.lines.each do |line|
  url = URI.parse(line.chomp)

  res = Net::HTTP.get_response(url)

  code = res.code.to_i
  if code < 200 || 300 <= code
    puts "Did not receive successful HTTP response. Code: #{code}"
    next
  end

  doc = Nokogiri::HTML5.parse(res.body)

  sources = doc.css('meta[property="og:video"]').filter_map { |meta| meta.attributes['content'].value }

  formats = %w[avi mp4 mkv webm]
  best_source = sources.max_by { |s| formats.index { |ext| s.end_with? ext } || 0 }

  destfile = File.join(destdir, File.basename(best_source))

  if File.exist? destfile
    puts "#{destfile} exists already. Skipping download of #{best_source}"
    next
  end

  puts "Downloading #{best_source} to #{destfile}..."

  wget(best_source, destfile)
end
