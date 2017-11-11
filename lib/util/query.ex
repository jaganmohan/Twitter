defmodule Util.Query do
    @moduledoc """
    Struct defining query.
    type: :all/:hashtags/:mentions
    tags: list of hashtags/mentions
    origin: origin of the query
    results: list of tweets
    """
    defstruct type: :all, tags: [], origin: nil, results: []
end