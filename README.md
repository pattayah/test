# test
This project is about synchronizing large amounts of data between different services, something we do daily at Wistia. Imagine a system where messages are placed onto a `queue`; a `processor` takes messages off the `queue`, performs some operations on them, and publishes the results to the `client`. We're interested in developing a scalable and efficient `processor`.

### System Description

1. Each message in the `queue` is a JSON string with a GUID `video_id` attribute, which is used by the client to identify a video.
2. Each message in the `queue` implies a "play" event for the `video_id` it references.
3. The `processor` is responsible for reading each message off the `queue`, updating the play count of the respective video, and publishing the result to the `client`.

### System Constraints

1. There are 100,000 messages on the `queue` combined for 100 videos. Some videos have more plays than other videos. You can decide on the distribution of 100,000 plays across the 100 videos, but ensure there are at least 15 videos with fewer than 100 plays each.
2. For videos with fewer than 100 plays, the `processor` needs to the publish the result to the `client` as soon as a play is received for one because with such a small sample size, each play is of the utmost "realtime" importance.
3. For videos with 100 or more plays, each play is a little less significant, and so their stats do not need to be as "realtime." Rather, the `client` just needs to have the total play count for these videos up to date for the last 1 minute, i.e. each message that arrives on the `queue` must manifest as a change in the total play count for the associated `video_id` within 1 minute of arriving on the queue.
4. Each time the `processor` publishes (i.e. makes a call to) to the `client`, it can provide updated play counts for at most 20 videos in a single message.
5. An updated play count for a video should _only_ be published to the `client` if the play count for that video has changed since it was last published.
6. The goal is to minimize the number of times the `processor` publishes its results to the `client`. Imagine that the cost of each request made is high.

### Your Task

Based on the aforementioned constraints, write a script that produces messages onto a `queue`, and create the `processor` that consumes from that `queue` and publishes its results to the `client`.

### Notes

1. For the `queue`, please use [NSQ](http://nsq.io/), a distributed messaging platform that Wistia uses for data ingestion. Download and install it. To run it, we suggest looking at [`nsq-cluster`](https://github.com/wistia/nsq-cluster), a ruby script that spins up NSQ locally.
2. To interface with NSQ, please use [`nsq-ruby`](https://github.com/wistia/nsq-ruby), a client library that lets you produce to and consume from NSQ.
3. Publishing to the `client` can be as trivial as logging to `STDOUT` or as complex as a webpage that updates with the total play count of each video. This is totally up to you!
