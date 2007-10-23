#
# = rails_async_callback.rb
#
# Copyright (c) 2007 SUGAWARA Genki <sgwr_dts@yahoo.co.jp>
#
# == Example
#
#     class FooController < ApplicationController
#       def index
#
#         # asynchronous callback
#         RailsAsyncCallback.invoke('foo', 'bar', 'zoo') do |*args|
#           args.each do |arg|
#             puts arg
#             sleep 2
#           end
#         end
#
#         # for ActiveRecord
#         RailsAsyncCallback.invoke(Book) do |book_class|
#           book_class.find(:all).each do |book|
#             puts book
#             sleep 2
#           end
#         end
#
#         render :text => 'hello'
#       end
#     end
#

if defined?(RailsAsyncCallback)
  RailsAsyncCallback.stop
end

class RailsAsyncCallback
  @@queue = Queue.new
  @@error_handler = nil

  Thread.fork do
    while func_args = @@queue.pop
      func, args = func_args

      Thread.fork do
        begin
          func.call(*args)
        rescue Exception => e
          if @@error_handler
            @@error_handler.call(e)
          elsif @@error_handler != false
            puts_exception(e)
          end
        end
      end
    end
  end

  def self.invoke(*args, &block)
    @@queue.push([block, args])
  end

  def self.stop
    @@queue.push(nil)
  end

  def self.set_error_handler(&block)
    @@error_handler = block
  end

  def self.puts_exception(e, out = $stderr)
    backtrace = e.backtrace
    head = "#{backtrace.first}: #{e.message} (#{e.class})"
    rest = backtrace.slice(1..-1).map {|i| "\tfrom #{i}" }
    out.puts(([head] + rest).join($/))
  end

  private_class_method :puts_exception
end
