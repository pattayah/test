# HOW DO I LOAD THE MESSAGING PLATFORM, CLUSTER, AND LIBRARY???
require 'nsq'

# Start a queue of 100_000 nsqd's and 100 video_id's.
# This will block execution until all components are fully up and running.
queue1 = NsqCluster.new(message: 90_000, video_id: 50)		# videos with more than 100 plays
queue2 = NsqCluster.new(message: 1_000, video_id:50)			# videos with fewer than 100 plays
queue = queue1.merge(queue2)

# Connect directly to a single nsqd instance
nsqd = queue.nsqd.first			# DO I DO THIS OR NSQLOOKUP BELOW???

# processor initialization
processor = Nsq::Consumer.new(
	topic: 'topic',
	channel: 'channel',
	nsqlookupd: queue,			# DO I DO THIS OR NSQD ABOVE???
	discovery_interval: ,		# SHOULD THIS BE LOW SO CAN CHECK IN REAL TIME OR DEFAULT BECAUSE WE NEED TO UPDATE EVERY MINUTE
	max_in_flight: 20			# IS THIS RIGHT???
	)

client = Logger.new

# HOW DO I PROVIDE PLAYCOUNTS FOR UP TO 20 VIDEOS IN A SINGLE MESSAGE???
# HOW DO I MAKE SURE THE PLAY COUNT IS ONLY PUBLISHED IF IT'S CHANGED SINCE IT WAS LAST PUBLISHED???

class processor < Nsq::Consumer

	# initialize play count at 0
	@@count = {}

	def initialize(msg, video_id)
		@msg = msg
		@video_id = video_id
		@@count[video_id] = {}
	end

	# counts the plays
	def play_count
		@msg = client.pop
	end

	# real-time updates for videos with under 100 plays
	def push_under_100 (video_id)
		if @count < 100

		else
			push_over_100
		end
	end

	# wait to push for videos with over 100 plays
	def push_over_100 (video_id)

	end

end

# IDK IF THIS IS RIGHT???
Nsq.client = Logger.new(STDOUT)
