## What decisions have been made?

This task is done accroding to a document but a couple of decisions were left to me.
I decided to ass persistency layer with Postgres so a custommer could reuse exosting jobs afterwards. I decidede to use only one real table for tasks and job itself is just an uuid the tasks a grouped around.

I decided to add a couple of endpoints for custommer convinience to list and retrieve already created jobs.

JSON / Bash format are determined from `Accepted` header mime-type. If `application/json` is accepted, JSON is returned, if `text/x-shellscript` is accepted, bash script is returned.

For building DAG I used `libgraph` as it is an Elixir not Erlang as `:digraph` and it is more convenient to use in Elixir code. Using postgres side logic seems to be overcomplicated for it.

In DB tasks dependencies are stored as an array, not as relationships because in this exact case it's much more simple and there are no real usecase for relationships in the project.

I tried to follow Phoenix / Ecto philosophy and style as much as possible since it's much quicker and easier for this test cese. I could do it in pure cowboy or bandit but see no reason in ti.

I wrote most of tghe code by hand but used Claude for assistance with brushing up the code in the end and updating docs.
