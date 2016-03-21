#! /usr/bin/env ruby

require_relative 'lib/kgrader'

def main
  cli = KGrader::CLI.new
  cli.test
end

main
