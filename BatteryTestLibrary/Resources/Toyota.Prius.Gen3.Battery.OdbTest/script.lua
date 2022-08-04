-- pretest script
function Pretest()
    --AddErrorLogEntry("Pretest Error Log Entry")
    AddAdhocLogEntry("GEN3 PRIUS TEST")

    ProcessRequest("0902", function(response)
        IterateThroughSignals(response, "PRE-TEST")
        AddSignalsToAdhocLog(response)
    end)

    return 10
end

function AddSignalsToAdhocLog(signals)
    for k,v in pairs(signals) do
        AddAdhocLogEntry(k .. " : " .. v)
    end
end

function IterateThroughSignals(signals, title)
    print(" ")
    print("======================  LUA PROCESS REQUEST " .. title .. " RESULT START ======================")
    for k,v in pairs(signals) do
        print(k, ":", v)
    end
    print("======================   LUA PROCESS REQUEST " .. title .." RESULT END  ======================")
    print(" ")
end

-- optional: used to generate EXCEL spread sheet header text for processed signals
-- return: a table of header strings (ShortNames and Header Strings).  Key value, as returned by Sample function, is used if no header is provided here.
function GetSampleHeaders()
    return { }
end

-- optional: called immediately after every sample
-- seconds: the remaining test time, in seconds
-- signals: the sampled OBD2 signals 
-- return: a table of processed signal variables (ShortNames and Values)
function Sample(seconds, signals)
    IterateThroughSignals(signals, "SAMPLE [" .. seconds .. "s]" )

    return { 
        V01 = (signals.BV_A * 256 + signals.BV_B) * 79.99 / 65535,
        V02 = (signals.BV_C * 256 + signals.BV_D) * 79.99 / 65535,
        V03 = (signals.BV_E * 256 + signals.BV_F) * 79.99 / 65535,
        V04 = (signals.BV_G * 256 + signals.BV_H) * 79.99 / 65535,
        V05 = (signals.BV_I * 256 + signals.BV_J) * 79.99 / 65535,
        V06 = (signals.BV_K * 256 + signals.BV_L) * 79.99 / 65535,
        V07 = (signals.BV_M * 256 + signals.BV_N) * 79.99 / 65535,
        V08 = (signals.BV_O * 256 + signals.BV_P) * 79.99 / 65535,
        V09 = (signals.BV_Q * 256 + signals.BV_R) * 79.99 / 65535,
        V10 = (signals.BV_S * 256 + signals.BV_T) * 79.99 / 65535,
        V11 = (signals.BV_U * 256 + signals.BV_V) * 79.99 / 65535,
        V12 = (signals.BV_W * 256 + signals.BV_X) * 79.99 / 65535,
        V13 = (signals.BV_Y * 256 + signals.BV_Z) * 79.99 / 65535,
        V14 = (signals.BV_AA * 256 + signals.BV_AB) * 79.99 / 65535,
        V_AuxBV = (signals.AuxB_AC * 256 + signals.AuxB_AD) * 79.9 / 65535 - 40,
        PwrResBV = (signals.PR_AE * 256 + signals.PR_AF) / 10,
    }
end

function PostTest(sampleTimes, samples)
    for i=1,#samples do
        sample = samples[i]
        IterateThroughSignals(sample, "POST-TEST [" .. sampleTimes[i] .. "s]")
    end
end
