### This is YET ANOTHER COMMAND LINE ARGUMENT MODULE.
..or maybe it's the first.


---
**Command-line argument module for CC:Tweaked packed in with autocomplete functionality.**

Usage is simple. You create your flags as if it were done in Go:
```lua
local cla = dofile("./cla.lua");
cla.String("foo", "bar", "Creates a new test foo variable.");
cla.Integer("bar", 4, "Creates a new test bar variable.");
cla.Valueless("baz", "Creates a new test baz variable.");
cla.Boolean("quz", true, "Creates a new test quz variable.");
cla.Float("qux", 2.5, "Creates a new test qux variable.");
```

After, you run `cla.Parse` with the calling arguments `{...}` as the first argument.
This returns a table of all arguments (both modified and unmodified)

```lua
local parsedFlags = cla:Parse({...});
for _, Flag in pairs(parsedFlags) do
  if (Flag.modified) then
    ...
  end
end
```

### cla.String
Creates a String flag for YACLAM.
```lua
cla.String("foo", "bar", "Creates a new test foo variable.");
```

### cla.Integer
Creates an Integer flag for YACLAM. This can unfortunately get confused with Float in some cases, therefore this implementation can also accept floats - provided that they are among the lines of "x.0".
```lua
cla.Integer("bar", 4, "Creates a new test bar variable.");
```
### cla.Valueless
Creates a Valueless flag for YACLAM. When creating a flag like this, no value is to be expected - hence Valueless.
```lua
cla.Valueless("baz", "Creates a new test baz variable.");
```

### cla.Boolean
Creates a Boolean flag for YACLAM.
```lua
cla.Boolean("quz", false, "Creates a new test quz variable.");
```

### cla.Float
Creates a Float flag for YACLAM. This can unfortunately get confused with Integer in some cases, therefore this implementation can also accept integers.
```lua
cla.Float("qux", 4.5, "Creates a new test qux variable.");
```

## Notable features

### Neat error handling if a wrong type is provided 

For example, let's say you have some form of antique dementia and forget that the function name is String:
```lua
local cla = require("./cla.lua");
cla.String("foobar", 4.5, "Sets application name.");
```

You will then get shouted at by the program:

![image](https://user-images.githubusercontent.com/16274568/123170311-39034880-d42f-11eb-8efe-e5f81109c17d.png)

### Notice for when a wrong type is given to a flag

If your user forgets to read the documentation, there's no problem! No more pesky users DMing you on Discord complaining that your flag doesn't work. The program tells them to shut up for you! It also adopts the same amount of dashes for the same input. Oh, and it also has pretty colours!

![image](https://user-images.githubusercontent.com/16274568/123170631-97302b80-d42f-11eb-8237-5946c36ca4d0.png)
![image](https://user-images.githubusercontent.com/16274568/123170777-c6469d00-d42f-11eb-957f-131930c6449e.png)

### More lenient than the American government.

I'm poking at a rattlesnake with this header. Regardless, it doesn't matter if you're computer-illiterate or not, the program will allow you to set one-dash arguments in almost any way possible:

![image](https://user-images.githubusercontent.com/16274568/123171566-d90da180-d430-11eb-85ca-93dc13b640b0.png)

Oh, by the way, that implementation by itself took a good thirty-five lines to do. You're welcome, computer-illiterate people.

### The sexiest autocomplete on the goddamn planet.

Guess what? You don't even need documentation! The program does it for you, at the expense of the user being unable to fully autocomplete via the 'tab' key. It also packs in the equal sign in cases where the user utilizes single-dash command-line arguments and if the closest value isn't a valueless flag. It, unfortunately or fortunately - **doesn't support the user being a gremlin and typing their argument similarly to "c =a", "c = a", or "c= a".**

![image](https://user-images.githubusercontent.com/16274568/123170971-03129400-d430-11eb-9161-63d6bbff2a83.png)
![image](https://user-images.githubusercontent.com/16274568/123171161-466d0280-d430-11eb-8efc-2282f66220d5.png)

### Works on colourless displays, however, it defaults to white.

'Nuff said.

### Allows you to mix and match types of arguments.

Are you bipolar and indecisive? Yes, those two terms are very distant, but don't worry about the details. This module allows you to do both `x=y` and `--x y`!
If you do this, please be aware that I hate you.

![image](https://user-images.githubusercontent.com/16274568/123172156-91d3e080-d431-11eb-9e4e-8b0c2d69151c.png)

### Alzheimers' Condom

No, the Alzheimer Condom isn't actually a condom for Alzheimer's. It's a condom in the sense that it protects you from your alzheimers' kicking in and forgetting that you need to type a value for the flag. This works both for single-dash arguments (to an extent) and double-flag arguments fully.

![image](https://user-images.githubusercontent.com/16274568/123179436-3eb45a80-d43e-11eb-8158-46e89f79cafc.png)

