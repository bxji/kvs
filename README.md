# kvs
Distributed Key-Value Store

Requires Docker.
Build script defaults to 6 containers, more can be created with a few easy modificaitons.

Developed in conjunction with The 20 Buddies

### Starting Key-value Store
To start a key value store we use the following environmental variables. 

* "S" is the number of replicas per partition. Each partition (having k replicas) owns a subset of keys.
* "VIEW" is the list of ip:ports pairs of nodes.
* "IPPORT" is the ip address and port of the node.

An example of starting a key-value store with 4 nodes and partition size 2:

```
docker run -p 8081:8080 --ip=10.0.0.21 --net=mynet -e S=2 -e VIEW="10.0.0.21:8080,10.0.0.22:8080,10.0.0.23:8080,10.0.0.24:8080" -e ip_port="10.0.0.21:8080" mycontainer
docker run -p 8082:8080 --ip=10.0.0.22 --net=mynet -e S=2 -e VIEW="10.0.0.21:8080,10.0.0.22:8080,10.0.0.23:8080,10.0.0.24:8080" -e ip_port="10.0.0.22:8080" mycontainer
docker run -p 8083:8080 --ip=10.0.0.23 --net=mynet -e S=2 -e VIEW="10.0.0.21:8080,10.0.0.22:8080,10.0.0.23:8080,10.0.0.24:8080" -e ip_port="10.0.0.23:8080" mycontainer
docker run -p 8084:8080 --ip=10.0.0.24 --net=mynet -e S=2 -e VIEW="10.0.0.21:8080,10.0.0.22:8080,10.0.0.23:8080,10.0.0.24:8080" -e ip_port="10.0.0.24:8080" mycontainer
```
### Partition Functions

#### GET /shard/my_id

Returns the container’s shard id
```
{
  “id”:<container’sShardId>
}
```
HTTP Status Code = 200


#### GET /shard/all_ids

Returns a list of all shard ids in the system as a string of comma separated values.

```
{
  “result”: “Success”,
  “shard_ids”: “0,1,2”
}
```
HTTP Status Code = 200


#### GET /shard/members/<shard_id>

Returns a list of all members in the shard with id <shard_id>. Each member is represented as an ip-port address. (the same one you pass into VIEW)

```
{
  “result” : “Success”,
  “members”: “176.32.164.2:8080,176.32.164.3:8080”
}
```
HTTP Status Code = 200

If the <shard_id> is invalid:

```
{
  “result”: “Error”,
  “msg”: “No shard with id <shard_id>”
}
```
HTTP Status Code = 404


#### GET /shard/count/<shard_id>

Returns the number of key-value pairs that shard is responsible for as an integer

```
{
  “result”: “Success”,
  “Count”: <numberOfKeys> 
}
```
HTTP Status Code = 200

If the <shard_id> is invalid, returns:
```
{
  “result”: “Error”,
  “msg”: “No shard with id <shard_id>”
}
```
HTTP Status Code = 404

#### PUT /shard/changeShardNumber -d=”num=<number>”

Initiates a change in the replica groups such that the key-values are redivided across <number> groups and returns a list of all shard ids, as in GET /shard/all_ids
```
{
  “result”: “Success”,
  “shard_ids”: “0,1,2”
}
```
HTTP Status Code = 200

If <number> is greater than the number of nodes in the view, returns:
```
{
  “result”: “Error”,
  “msg”: “Not enough nodes for <number> shards”
}
```
HTTP Status Code = 400

If there is only 1 node in any partition as a result of redividing into <number> shards, aborts the operation and returns:
```
{
  “result”: Error”,
  “msg”: “Not enough nodes. <number> shards result in a nonfault tolerant shard”
}
```
HTTP Status Code = 400
  
The only time one should have 1 node in a shard is if there is only one node in the entire system. In this case it should only return an error message if you try to increase the number of shards beyond 1.
