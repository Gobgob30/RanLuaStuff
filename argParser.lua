return function(file_name, arg_name_list, required, ...)
    local args = { ... }
    local return_args = {}
    for i = 1, #arg_name_list do
        if required[i] and not args[i] then
            print("Argument required:", arg_name_list[i])
            print("Usage:", file_name, table.concat(arg_name_list, " "))
            print("Arguments:", table.concat(args, " "))
            return nil, "Argument required " .. arg_name_list[i]
        end
        return_args[arg_name_list[i]] = args[i]
    end
    return return_args
end
