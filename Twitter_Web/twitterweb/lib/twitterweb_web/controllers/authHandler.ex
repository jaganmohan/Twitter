defmodule TwitterwebWeb.AuthHandler do
    use TwitterwebWeb, :controller

    def register(conn, _params) do
        json conn, %{msg: "Coming to register"}
    end

    def login(conn, _params) do
        
    end

    def logout(conn, _params) do
        
    end
    
end