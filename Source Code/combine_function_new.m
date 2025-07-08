function dsnew = combine_function_new(dsList, opts)
            %COMBINE  Create a CombinedDatastore or SequentialDatastore by

            arguments (Repeating)
                dsList {matlab.io.datastore.internal.validators.mustBeDatastore(dsList, "MATLAB:datastoreio:combineddatastore:invalidInputs")}
            end

            arguments
                opts.ReadOrder (1,1) string = "associated"
            end

            ReadOrder = validatestring(opts.ReadOrder, ["associated", "sequential"], "combine", "ReadOrder");

            switch ReadOrder
                case "sequential"
                    dsnew = matlab.io.datastore.SequentialDatastore(dsList{:});
                case "associated"
                    dsnew = matlab.io.datastore.CombinedDatastore(dsList{:});
            end
        end