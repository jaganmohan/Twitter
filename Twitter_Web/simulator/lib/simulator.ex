defmodule Simulator do
      use GenServer
  
  def main(argv) do
   # start_link()
                 
     GenServer.start_link(__MODULE__,[],name: Simulator)     
    arg=List.wrap(argv);
    numClients= String.to_integer(List.first(arg))
   
    for i <- 1..numClients do
             clientName = "user#{i}"           
             clientPID = SocketClient.start_link({i, numClients}, [], 
              [name: String.to_atom(clientName)])          
    end
    receive do
      
    end
  end

  def init([]) do
    state=0;
    {:ok,state}
  end

end