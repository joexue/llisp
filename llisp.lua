--[[
-- LLisp, lisp interpreter written by Lua.
-- Joe Xue(lgxue@Hotmail.com) 2026
--]]

STACK = {}
ATOM = {"ERR", "#t"}

NIL = {"NIL", 0}
ERR = {"ATOM", 1}
TRUE = {"ATOM", 2}
ENV = {}

function is_equ(x, y)
    return x[1] == y[1] and x[2] == y[2]
end

function is_nil(x)
    return x[1] == "NIL"
end

function assoc(x, e)
    while e[1] == "CONS" and not is_equ(x, car(car(e))) do
        e = cdr(e)
    end

    if e[1] == "CONS" then
        return cdr(car(e))
    end

    return ERR
end

function eval(x, e)
    if x[1] == "ATOM" then
        return assoc(x, e)
    elseif x[1] == "CONS" then
        return apply(eval(car(x), e), cdr(x), e)
    else
        return x
    end
end

function evlis(x, e)
    if x[1] == "CONS" then
        return cons(eval(car(x), e), evlis(cdr(x), e))
    elseif x[1] == "ATOM" then
        return assoc(x, e)
    else
        return NIL
    end
end

function cons(x, y)
    table.insert(STACK, x)
    table.insert(STACK, y)

    return {"CONS", #STACK}
end

function car(x)
    if x[1] == "CONS" or x[1] == "CLOS" then
        return STACK[x[2] - 1]
    end

    return ERR;
end

function cdr(x)
    if x[1] == "CONS" or x[1] == "CLOS" then
        return STACK[x[2]]
    end

    return ERR;
end

function pair(k, v, e)
    return cons(cons(k, v), e)
end

function closure(v, x, e)
    if is_equ(e, ENV) then
        e = NIL
    end

    return {"CLOS", pair(v, x, e)[2]}
end

function let(x)
    return not is_nil(x) and not is_nil(cdr(x))
end

PRIM = {
    {
        "eval",
        function(t, e)
            return eval(car(evlis(t, e)), e);
        end
    },
    {
        "car",
        function(t, e)
            return car(car(evlis(t,e)))
        end
    },
    {
        "-",
        function(t, e)
            t = evlis(t, e)
            local n = car(t)[2]

            t = cdr(t)
            while not is_nil(t) do
                n = n - car(t)[2]
                t = cdr(t)
            end
            return {"NUMBER", n}
        end
    },
    {
        "<",
        function(t, e)
            t = evlis(t,e)
            if car(t)[2] - car(cdr(t))[2] < 0 then
                return TRUE
            else
                return NIL
            end
        end
    },
    {
        "or",
        function(t, e)
            local x = NIL;

            while not is_nil(t) do
                x = eval(car(t), e)
                if is_nil(x) then
                    t = cdr(t)
                else
                    break
                end
            end

            return x;
        end
    },
    {
        "cond",
        function(t, e)
            while is_nil(eval(car(car(t), e))) do
                t = cdr(t)
            end
            return eval(car(cdr(car(t))), e)
        end
    },
    {
        "lambda",
        function(t, e)
            return closure(car(t), car(cdr(t)), e);
        end
    },
    {
        "quote",
        function(t, e)
            return car(t)
        end
    },
    {
        "cdr",
        function(t, e)
            return cdr(car(evlis(t,e)))
        end
    },
    {
        "*",
        function(t, e)
            t = evlis(t, e)
            local n = car(t)[2]

            t = cdr(t)
            while not is_nil(t) do
                n = n * car(t)[2]
                t = cdr(t)
            end
            return {"NUMBER", n}
        end
    },
    {
        "int",
        function(t, e)
            local n = car(evlis(ta ,e));
            return {"NUMBER", math.floor(n[2])}
        end
    },
    {
        "and",
        function(t, e)
            local x = TRUE;

            while not is_nil(t) do
                x = eval(car(t), e)
                if not is_nil(x) then
                    t = cdr(t)
                else
                    break
                end
            end

            return x;
        end
    },
    {
        "if",
        function(t, e)
            local n = eval(car(t), e)
            if is_nil(n) then
                t = cdr(t)
            end

            return eval(car(cdr(t)), e)
        end
    },
    {
        "define",
        function(t, e)
            ENV = pair(car(t), eval(car(cdr(t)), e), ENV);
            return car(t);
        end
    },
    {
        "cons",
        function(t, e)
            t = evlis(t, e)
            return cons(car(t), car(cdr(t)))
        end
    },
    {
        "+",
        function(t, e)
            t = evlis(t, e)
            local n = car(t)[2]

            t = cdr(t)
            while not is_nil(t) do
                n = n + car(t)[2]
                t = cdr(t)
            end
            return {"NUMBER", n}
        end
    },
    {
        "/",
        function(t, e)
            t = evlis(t, e)
            local n = car(t)[2]

            t = cdr(t)
            while not is_nil(t) do
                n = n / car(t)[2]
                t = cdr(t)
            end
            return {"NUMBER", n}
        end
    },
    {
        "eq?",
        function(t, e)
            t = evlis(t, e)
            if is_equ(car(t), car(cdr(t))) then
                return TRUE
            else
                return NIL
            end
        end
    },
    {
        "not",
        function(t, e)
            if is_nil(car(evlis(t, e))) then
                return TRUE
            else
                return NIL
            end
        end
    },
    {
        "let*",
        function(t, e)
            while true do
                if not let(t) then
                    break
                end
                e = pair(car(car(t)), eval(car(cdr(car(t))), e), e)
                t = cdr(t)
            end

             return eval(car(t), e);
        end
    },
    {
        "pair?",
        function(t, e)
            local x = car(evlis(t, e));
            if x[1] == "CONS" then
                return TRUE
            else
                return NIL
            end
        end
    }
}


function print_lisp(l)
    local print_list = function(l)
        io.write("(")
        while true do
            print_lisp(car(l))
            l = cdr(l)
            if is_nil(l) then
                break
            end
            io.write(" ")
        end
        io.write(")")
    end

    if l[1] == "NIL" then
        io.write("()")
    end

    if l[1] == "ATOM" then
        io.write(ATOM[l[2]])
    end

    if l[1] == "PRIM" then
        io.write("<" .. PRIM[l[2]][1] .. ">")
    end

    if l[1] == "CONS" then
        print_list(l)
    end

    if l[1] == "CLOS" then
        io.write("{" .. l[2] .. "}")
    end

    if l[1] == "NUMBER" then
        io.write(l[2])
    end
end

function get_scan(lisp)
    pos = 1
    return function()
        local token = {}
        --io.read()

        local c
        while true do
            -- First letter
            c = string.sub(lisp, pos, pos)
            if c ~= ' ' then
                break
            end
            pos = pos + 1
        end

        if c == '(' or c == ')' or c == '\'' or c == '' then
            -- Consume it
            pos = pos + 1
            return c
        end

        while true do
            --io.write(" 3-> " .. c .. " ")
            c = string.sub(lisp, pos, pos)
            if c == '(' or c == ')' or c == '\'' or c == ' ' or c == '' then
                -- Consume it next round
                break
            end
            table.insert(token, c)
            pos = pos + 1
        end
        return table.concat(token)
    end
end

function atomic(token)
    local n = tonumber(token)

    if not n then
        --default error
        local index = #ATOM + 1
        for i = 1, #ATOM do
            if ATOM[i] == token then
                index = i
                break
            end
        end

        if index == #ATOM + 1 then
            table.insert(ATOM, token)
        end

        return {"ATOM", index}
    end

    return {"NUMBER", n}
end

function parse(c, scan)
    parse_list = function(scan)
        local c = scan()
        if c == ')' then
            return NIL
        end

        local x = parse(c, scan)
        if is_equ(x, ERR) then
            return ERR
        end

        local y = parse_list(scan)
        if is_equ(y, ERR) then
            return ERR
        end
        return cons(x, y)
    end

    parse_quote = function(scan)
        return cons(atomic("quote"), cons(parse(scan(), scan), NIL))
    end

    if c == '(' then
        return parse_list(scan)
    elseif c == '\'' then
        return parse_quote(scan)
    elseif c == '' then
        return ERR
    else
        return atomic(c)
    end
end


function bind(v, t, e)
    if is_nil(v) then
        return e
    end

    if v[1] == "CONS" then
        return bind(cdr(v), cdr(t), pair(car(v), car(t), e))
    end

    return pair(v, t, e)
end

function reduce(f, t, e)
    local n
    if is_nil(cdr(f)) then
        n = ENV
    else
        n = cdr(f)
    end

    return eval(cdr(car(f)), bind(car(car(f)), evlis(t, e), n))
end

function apply(f, t, e)
    if f[1] == "PRIM" then
        return PRIM[f[2]][2](t, e)
    elseif f[1] == "CLOS" then
        return reduce(f, t, e);
    end

    return ERR
end

function read()
    local scan = get_scan(io.read())
    return parse(scan(), scan)
end

-- ENV initilization
ENV = pair(TRUE, TRUE, NIL)
for i = 1, #PRIM do
    ENV = pair(atomic(PRIM[i][1]), {"PRIM", i}, ENV)
end

io.write("LLisp -- Lisp interpreter written by Lua")
while true do
    io.write("\n> ")
    --print_lisp(read())
    print_lisp(eval(read(), ENV))
end
