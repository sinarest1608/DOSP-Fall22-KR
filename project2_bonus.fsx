#r "nuget: Akka"
#r "nuget: Akka.FSharp"
#r "nuget: Akka.TestKit"
#r "nuget: Akka.Remote"

open System
open System.Threading
open Akka.Actor
open Akka.Configuration
open Akka.FSharp

//user inputs
let system = ActorSystem.Create("Project2")
let mutable numNodes = fsi.CommandLineArgs.[1] |> int
let topology = fsi.CommandLineArgs.[2] |> string
let algorithm = fsi.CommandLineArgs.[3] |> string
let limitPerNode = 10
let sendLimitPerNode = 500
let random = System.Random()
let timer = System.Diagnostics.Stopwatch()

//Gossip Message
type GossipNodeMsg =
    | GetNeighbors of string*IActorRef*list<IActorRef>
    | RecieveRumor
    | SendRumor
    | Exhausted

//Push sum message
type PushSumNode =
    | GetNeighborsPushSum of string*IActorRef*list<IActorRef>
    | RecieveRumorPS of float*float
    | SendRumorPS
    | ExhaustedPS

//Message to build the topology
type BuildTopology = 
    | BuildTopology of string*list<IActorRef>
    | TopologyBuilt of string

//Dispatcher Message
type Dispatcher = 
    | TopologyDispatcher of string
    | StartGossip
    | StartPushSum
    | CountExhaustedNodes


let mutable Nodelist = []


//Gossip Node actor
let GossipNode(mailbox:Actor<_>)=
    let mutable neigbhours=[]
    let mutable numMsgesRecieved = 0
    let mutable nodetopology=""
    let mutable spreadcnt = 0
    let mutable count = 0
    let mutable exhausted = false
    let mutable dispatcherref = null
    let id = mailbox.Self.Path.Name |> int
    let rec loop() =actor{
        let! message = mailbox.Receive()
        match message with
        | GetNeighbors(topology,dref,neightborsList)->  neigbhours<-neightborsList
                                                        nodetopology<-topology
                                                        dispatcherref<-dref
                                                        mailbox.Sender()<!TopologyBuilt(topology)
        | RecieveRumor ->   if not exhausted then                  
                                numMsgesRecieved<-numMsgesRecieved+1
                            if numMsgesRecieved = limitPerNode then 
                                exhausted <- true
                                dispatcherref<!CountExhaustedNodes
                                if topology = "full" then
                                    for i in 0 .. numNodes-1 do 
                                        if i <> id then
                                            Nodelist.Item(i)<!Exhausted
                                else
                                    for i in 0 .. neigbhours.Length-1 do
                                        neigbhours.Item(i)<!Exhausted
                            else
                                mailbox.Self<!SendRumor
                        
        | SendRumor ->  if not exhausted then
                            let mutable next=random.Next()
                            if topology = "full" then
                                while next%numNodes=id do
                                        next<-random.Next()
                                Nodelist.Item(next%numNodes)<!RecieveRumor
                            else
                                neigbhours.Item(next%neigbhours.Length)<!RecieveRumor
                            spreadcnt <- spreadcnt + 1
                            if spreadcnt = sendLimitPerNode then
                                exhausted <- true
                                dispatcherref<!CountExhaustedNodes
                                if topology = "full" then
                                    for i in 0 .. numNodes-1 do 
                                        if i <> id then
                                            Nodelist.Item(i)<!Exhausted
                                else
                                    for i in 0 .. neigbhours.Length-1 do
                                        Nodelist.Item(i)<!Exhausted
                            else
                                mailbox.Self<!SendRumor

        | Exhausted ->  if exhausted then
                            dispatcherref<!CountExhaustedNodes
                        if not exhausted then
                            count <- count + 1
                            if topology = "full" then 
                                if count = numNodes-1 then 
                                    exhausted <- true
                                    dispatcherref<!CountExhaustedNodes
                            else
                                if count = neigbhours.Length then
                                    exhausted <- true
                                    dispatcherref<!CountExhaustedNodes
        return! loop()
    }
    loop()

//Push sum node actor
let PushSumNode(mailbox:Actor<_>)=
    let mutable neigbhours=[]
    let mutable nodetopology=""
    let mutable exhausted = false
    let mutable count = 0
    let mutable map = Map.empty
    let mutable ratioConvergenceCount = 0
    let mutable dispatcherref = null
    let id = mailbox.Self.Path.Name |> int
    let mutable s_existing = id|>float
    let mutable w_existing = 1.0
    let rec loop() =actor{
        let! message = mailbox.Receive()
        match message with
        | GetNeighborsPushSum(topology,dref,neightborsList)->   neigbhours<-neightborsList
                                                                nodetopology<-topology
                                                                dispatcherref<-dref
                                                                mailbox.Sender()<!TopologyBuilt(topology)
        | RecieveRumorPS(s,w) ->    if not exhausted then                  
                                        let totalS = s+s_existing
                                        let totalW = w+w_existing
                                        if abs((totalS/totalW)-(s_existing/w_existing))<0.0000000001 then
                                            ratioConvergenceCount <- ratioConvergenceCount + 1
                                        else
                                            ratioConvergenceCount <- 0
                                        if ratioConvergenceCount =3 then
                                            exhausted <- true
                                            dispatcherref<!CountExhaustedNodes
                                            if topology = "full" then
                                                for i in 0 .. numNodes-1 do 
                                                    if i <> id &&  not (map.ContainsKey(i%numNodes)) then
                                                        Nodelist.Item(i)<!ExhaustedPS
                                                        Nodelist.Item(i)<!RecieveRumorPS(totalS/2.0,totalW/2.0)
                                                        
                                            else
                                                for i in 0 .. neigbhours.Length-1 do
                                                    if not (map.ContainsKey(neigbhours.Item(i).Path.Name|>int)) then
                                                        neigbhours.Item(i)<!ExhaustedPS
                                                        neigbhours.Item(i)<!RecieveRumorPS(totalS/2.0,totalW/2.0)
                                        else
                                            s_existing <- totalS
                                            w_existing <- totalW
                                            mailbox.Self <! SendRumorPS
                        
        | SendRumorPS ->  if not exhausted then
                            let mutable next=random.Next()
                            s_existing <- s_existing/2.0
                            w_existing <- w_existing/2.0
                            if topology = "full" then
                                while next%numNodes=id || map.ContainsKey(next%numNodes) do
                                    next<-random.Next()
                                Nodelist.Item(next%numNodes)<!RecieveRumorPS(s_existing,w_existing)
                            else
                                while map.ContainsKey(neigbhours.Item(next% neigbhours.Length).Path.Name|>int) do
                                    next <- random.Next()
                                neigbhours.Item(next%neigbhours.Length)<!RecieveRumorPS(s_existing,w_existing)

        | ExhaustedPS ->    map <- map.Add(mailbox.Sender().Path.Name|>int,"true")
                            if not exhausted then
                                count <- count + 1
                                if topology = "full" then 
                                    if count = numNodes-1 then 
                                        exhausted <- true
                                        dispatcherref<!CountExhaustedNodes
                                else
                                    if count = neigbhours.Length then
                                        exhausted <- true
                                        dispatcherref<!CountExhaustedNodes
        return! loop()
    }
    loop()

//Topology builder actor
let Topology(mailbox:Actor<_>)=
    let mutable recorddone=0
    let mutable dispatcherref = null
    let rec loop() =actor{
        let! message = mailbox.Receive()
        match message with
        | BuildTopology(topology,nodelist)->    let mutable nlist=[]
                                                let mutable neighborlist = []
                                                dispatcherref<-mailbox.Sender()
                                                if(topology="line") then
                                                    for i in 0 .. numNodes-1 do
                                                        nlist <- []
                                                        if i <> 0 then
                                                            nlist <- nlist @ [nodelist.Item(i-1)]
                                                        if i <> numNodes-1 then
                                                            nlist <- nlist @ [nodelist.Item(i+1)]
                                                        if algorithm = "gossip" then
                                                            nodelist.Item(i)<!GetNeighbors(topology,dispatcherref,nlist)
                                                        else
                                                            nodelist.Item(i)<!GetNeighborsPushSum(topology,dispatcherref,nlist)
                                                elif topology="full" then
                                                    for i in 0 .. numNodes-1 do
                                                        //nodelist.Item(i)<!GetNeighbors(topology,dispatcherref,[])
                                                        if algorithm = "gossip" then
                                                            nodelist.Item(i)<!GetNeighbors(topology,dispatcherref,[])
                                                        else
                                                            nodelist.Item(i)<!GetNeighborsPushSum(topology,dispatcherref,[])
                                                elif topology="3D" || topology="imp3D" then
                                                    let numN = numNodes |> float
                                                    let k = System.Math.Cbrt(numN) |> int
                                                    numNodes <- k * k * k

                                                    for i in 0 .. numNodes - 1 do
                                                        nlist <- []
                                                        neighborlist <- []
                                                        let ksquared = k * k
                                                        let level = i / ksquared
                                                        let upperLimit = (level + 1) * ksquared
                                                        let lowerLimit = level * ksquared

                                                        if (i - k) >= lowerLimit then
                                                            neighborlist <- neighborlist @ [i - k]
                                                            nlist <- nlist @ [nodelist.Item(i-k)]

                                                        if (i + k) < upperLimit then
                                                            neighborlist <- neighborlist @ [i + k]
                                                            nlist <- nlist @ [nodelist.Item(i+k)]

                                                        if ((i - 1) % k) <> (k - 1) && (i - 1) >= 0 then //left
                                                            neighborlist <- neighborlist @ [i - 1]
                                                            nlist <- nlist @ [nodelist.Item(i - 1)]

                                                        if (i + 1) % k <> 0 then
                                                            neighborlist <- neighborlist @ [i + 1]
                                                            nlist <- nlist @ [nodelist.Item(i+1)]

                                                        if i + ksquared < numNodes then
                                                            neighborlist <- neighborlist @ [i + ksquared]
                                                            nlist <- nlist @ [nodelist.Item(i+ksquared)]

                                                        if i - ksquared >= 0 then
                                                            neighborlist <- neighborlist @ [i - ksquared]
                                                            nlist <- nlist @ [nodelist.Item(i-ksquared)]

                                                        // printfn "%i" nlist.Length
                                                        if topology = "imp3D" then 
                                                            let mutable item = random.Next(0, numNodes - 1)
                                                            while List.contains item neighborlist do
                                                                item <- random.Next(0, numNodes - 1)
                                                            nlist <- nlist @ [nodelist.Item(item)]    
                                                        //nodelist.Item(i)<!GetNeighbors(topology,dispatcherref,nlist)
                                                        if algorithm = "gossip" then
                                                            nodelist.Item(i)<!GetNeighbors(topology,dispatcherref,nlist)  
                                                        else
                                                            nodelist.Item(i)<!GetNeighborsPushSum(topology,dispatcherref,nlist)                                             
        | TopologyBuilt(topology) ->    //printfn "topology built"
                                        if recorddone=numNodes-1 then
                                            if algorithm = "gossip" then 
                                                dispatcherref<!StartGossip
                                            else
                                                dispatcherref<!StartPushSum
                                        recorddone<-recorddone+1
                        
        return! loop()
    }
    loop()

//Spawn actors according to a topology
let topologyref= spawn system "topology" Topology
if algorithm = "gossip" then
    Nodelist <- [for a in 0 .. numNodes-1 do yield(spawn system (string a) GossipNode)] 
else
    Nodelist <- [for a in 0 .. numNodes-1 do yield(spawn system (string a) PushSumNode)] 

//Dispatcher actor    
let Dispatcher(mailbox:Actor<_>)=
    let mutable sendCount = 0  
    let rec loop() =actor{
        let! message = mailbox.Receive()
        match message with
        | TopologyDispatcher(topology) ->   printfn "Buiding topology"
                                            topologyref <! BuildTopology(topology,Nodelist)
        | StartGossip ->    printfn "Gossip started"
                            Nodelist.Item(random.Next()%numNodes)<!RecieveRumor
                            timer.Start()
                                
        | StartPushSum ->   let ind = random.Next()%numNodes |> float
                            printfn "Start Push Sum"
                            Nodelist.Item(random.Next()%numNodes)<!RecieveRumorPS(ind,1.0)
                            timer.Start()                       
        | CountExhaustedNodes ->    sendCount <- sendCount + 1
                                    if sendCount = numNodes then 
                                        printfn "sendCount - %i" sendCount
                                        mailbox.Context.System.Terminate() |> ignore
                                        printfn "%s - %s - %i - %i" algorithm topology numNodes timer.ElapsedMilliseconds
        return! loop()
    }
    loop()




let Dispatcherref = spawn system "Dispatcher" Dispatcher  

Dispatcherref<!TopologyDispatcher(topology)

system.WhenTerminated.Wait()