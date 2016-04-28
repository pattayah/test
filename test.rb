# HOW DO I LOAD THE MESSAGING PLATFORM, CLUSTER, AND LIBRARY???

# Start a queue of 100_000 nsqd's and 100 video_id's.
# This will block execution until all components are fully up and running.
queue = NsqCluster.new(message: 100_000, video_id: 100)

# Connect directly to a single nsqd instance
nsqd = queue.nsqd.first			# DO I DO THIS OR NSQLOOKUP BELOW???

# client initialization
client = Nsq::Consumer.new(
	topic: 'topic',
	channel: 'channel',
	nsqlookupd: queue,			# DO I DO THIS OR NSQD ABOVE???
	max_in_flight: 20			# max number of messages to have in flight at a time
	)

play_count = Hash.new(0)

# count the plays
queue.each do | msg, id |
	play_count[id] += 1
	if play_count[id] < 100 && # hasn't updated????
		# publish to the client asap
		# DO I USE THIS OR POP_WITHOUT_BLOCKING LIKE BELOW???
		processor = client.pop
	else
		# play count needs to be up to date for the last minute
		sleep 0.01
	end
end

# HOW DO I PROVIDE PLAYCOUNTS FOR UP TO 20 VIDEOS IN A SINGLE MESSAGE???
# HOW DO I MAKE SURE THE PLAY COUNT IS ONLY PUBLISHED IF IT'S CHANGED SINCE IT WAS LAST PUBLISHED???


# If there are messages on the queue, pop will return one immediately
# DO I USE THIS OR POP WITH BLOCKING LIKE ABOVE???
loop do
  if processor = @messages.pop_without_blocking
    # do something
    processor.finish
  else
    # wait for a bit before checking for new messages
    sleep 0.01
  end
end

# Publish a message to a topic
nsqd.pub('stats', 'a message')

# Get stats in JSON format
nsqd.stats

# To enable logging
Nsq.client = Logger.new(STDOUT)
