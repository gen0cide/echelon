#!/usr/bin/env ruby
# ---------------------------------------------------------------------------------------
# Echelon
# ICAP Prototype Server
# - By Alex Levinson
# - May 25th, 2012
# ---------------------------------------------------------------------------------------
require 'bundler'
Bundler.require(:icap)
# ---------------------------------------------------------------------------------------
class Settings < Settingslogic
  source "#{ARGV[0]}"
end
# ---------------------------------------------------------------------------------------
class Echelon < EM::Connection

  def post_init
    cleanup
  end

  def receive_data(packet)
    @data << packet
    if @icap_header[:data] == "" and pos = (@data =~ /\r\n\r\n/)
      @icap_header[:data] = @data[0..pos+1]
      if @icap_header[:data] =~ /^((OPTIONS|REQMOD|RESPMOD) icap:\/\/([A-Za-z0-9\.\-:]+)([^ ]+) ICAP\/1\.0)\r\n/
        req                 = $1
        @icap_header[:mode] = $2
        @icap_header[:host] = $3
        @icap_header[:path] = $4
        @icap_header[:data][req.size+2..@icap_header[:data].size-1].scan(/([^:]+): (.+)\r\n/).each do |h|
          @icap_header[:hdr][h[0]] = h[1]
        end
      else
        # puts "Error with ICAP header! Exiting!" ; exit 1
        # TODO: Having problems when this uncommented
      end
      @data = @data[pos+4..@data.size-1]
    end
    case @icap_header[:mode]
    when 'OPTIONS'
      method = @icap_header[:path] == '/request' ? 'REQMOD' : 'RESPMOD'
      send_data("ICAP/1.0 200 OK\r\nMethods: #{method}\r\n\r\n")
      cleanup
    when 'REQMOD'
      request_raw     = @data.dup.split(/\r\n/)
      request         = request_raw[0]
      request_headers = {}
      request_raw[1..-1].each do |line|
        line.scan(/([^:]+): (.+)/).each do |field|
          request_headers[field[0]] = field[1]
        end
      end
      if request =~ /^GET/
        if request =~ /#{Settings.domain}/
          puts "Modifying Request: #{request}"
          puts "Headers: #{request_headers.inspect}"
          @data.gsub!(request_headers["User-Agent"], Settings.useragent)
          response = "ICAP/1.0 200 OK\r\nDate: #{Time.now.strftime("%a, %d %b %Y %X %Z")}\r\nServer: RubyICAP\r\nConnection: close\r\nEncapsulated: req-hdr=0, null-body=#{@data.bytesize}\r\n\r\n#{@data}"
          send_data(response)
        else
          puts "No Modification for: #{request}"
          nocontent
        end
      else
        puts "No Modification for: #{request}"
        nocontent
      end
      cleanup
    when 'RESPMOD'
      nocontent
      cleanup
    else
    end
  end

  def nocontent
    send_data("ICAP/1.0 204 No Content.\r\n\r\n")
  end

  def cleanup
    @data        = ""
    @body        = ""
    @icap_header = { 
      :data => "", 
      :mode => "", 
      :path => "", 
      :hdr  => {}
    }
  end

end
# ---------------------------------------------------------------------------------------
EM.run do
  EM.start_server Settings.host, Settings.port, Echelon
  puts "== Ruby ICAP Server Started =="
end
# ---------------------------------------------------------------------------------------