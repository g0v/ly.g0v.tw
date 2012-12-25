# Services

# Create an object to hold the module.
mod = LYService: <[$http]> +++ ($http) ->
    mly = []
    $http.get '/data/mly-8.json' .success -> mly := it
    do
        resolveParty: (n) ->
            [party] = [party for {party,name} in mly when name is n]
            party

angular.module 'app.services' [] .factory mod
