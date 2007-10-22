# 
# = masuda.rb
# 
# Copyright (c) 2007 SUGAWARA Genki <sgwr_dts@yahoo.co.jp>
# 
# == Example
# 
#     require 'masuda'
#     class FooController < ApplicationController
#       def index
#         AsyncCallback.invoke('foo', 'bar', 'zoo') do |*args|
#           args.each do |arg|
#             puts "#{arg}"
#             sleep 2
#           end
#         end
# 
#         render :text => 'hello'
#       end
#     end
# 

if defined?(AsyncCallback)
  AsyncCallback.stop
end

class AsyncCallback
  @@queue = Queue.new

  Thread.fork do
    while func_args = @@queue.pop
      func, args = func_args
      Thread.fork { func.call(*args) }
    end
  end

  def self.invoke(*args, &block)
    @@queue.push([block, args])
  end

  def self.stop
    @@queue.push(nil)
  end
end
