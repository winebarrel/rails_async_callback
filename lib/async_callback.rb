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
