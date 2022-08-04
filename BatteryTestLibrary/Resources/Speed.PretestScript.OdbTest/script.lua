-- pretest script
function Pretest()
    AddErrorLogEntry("Pretest Error Log Entry")
    AddAdhocLogEntry("Pretest Adhoc Log Entry")

    ProcessRequest("0902", function(response)
        IterateThroughSignals(response)
    end)

    return 10
end

function IterateThroughSignals(signals)
    print(" ")
    print("======================  LUA PROCESS REQUEST RESULT ======================")
    for k,v in pairs(signals) do
        print(k, ":", v)
        --AddAdhocLogEntry(signal.ShortName .. " : " .. signal.Value)
    end
    print("======================  LUA PROCESS REQUEST RESULT ======================")
    print(" ")
end

-- optional: used to generate EXCEL spread sheet header text for processed signals
-- return: a table of header strings (ShortNames and Header Strings).  Key value, as returned by Sample function, is used if no header is provided here.
function GetSampleHeaders()
    return { Z="Speed * 2 * SIN(theta)"}
end

-- optional: called immediately after every sample
-- seconds: the remaining test time, in seconds
-- signals: the sampled OBD2 signals 
-- return: a table of processed signal variables (ShortNames and Values)
function Sample(seconds, signals)
    IterateThroughSignals(signals)

    z = signals["VehicleSpeed"] * 2
    theta = seconds / 10  * 2 * 3.14159
    return { Remaining=seconds, Z= z * math.sin(theta) }
end

function PostTest(sampleTimes, samples)
    for i=1,#samples do
        sample = samples[i]
        IterateThroughSignals(sample)
    end
end
