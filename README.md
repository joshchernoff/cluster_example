# ClusterExample

This is a basic exmaple of using Docker to build mix releases and spin nodes. 

In this case its two known nodes app@foo.dev and app@bar.dev. 

Using the ERL_DIST_PORT env we bypass epmd and specify which port erlang should try to cluster on.

From there we use libcluster and a very basic epmd Strategy with the two known nodes hard coded in the hosts. 


To start your Phoenix server:

  * Build containers `docker compose build`
  * Spin up `docker compose up`

Now you can visit [`localhost:4001`](http://localhost:4001) for app@foo.dev and [`localhost:4002`](http://localhost:4002) for app@bar.dev

LiveView should be running a very basic Blog post index. 

Currently its set to subscribe and handle new blog post submitions
