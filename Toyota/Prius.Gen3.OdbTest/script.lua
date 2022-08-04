--[[
    Optional function called before sampling starts

    void Pretest()

]]
function Pretest()

    --AddErrorLogEntry("Pretest Error Log Entry")
    AddAdhocLogEntry("GEN3 PRIUS TEST")

    ProcessRequest("0902", function(response)
        IterateThroughSignals(response, "PRE-TEST")
        AddSignalsToAdhocLog(response)
    end)

    --[[
        Create a new (first) ResultsPage (for displaying a 1D table of sample results)  

        static resultsPage CreateResultsPage(string name, string icon)

        where:
            - resultsPage is a new ResultsPage object
    ]]
    resultsPage0 = CreateResultsPage("Sample Data", "")

    --[[
        Layout the page into two columns, the right one sized to fit its contents, the left sized for the remaining space

        void resultsPage.Columns(params[] format)

        where:
            - resultsPage is a ResultsPage object
            - format can be one of:
                - size to fit content: "auto"
                - fixed pixels: a number
                - remaining space: "*" or "n*", where n is an integer representing a portion of the remaining space when shared.
    ]]
    resultsPage0.Columns("*", "auto")
    
    --[[
        Layout the page into two rows, the top one being 3/5 the available space and the bottom being 2/5 of the available space

        void resultsPage.Rows(params[] format)

        where:
            - resultsPage is a ResultsPage object
            - format can be one of:
                - size to fit content: "auto"
                - fixed pixels: a number
                - remaining space: "*" or "n*", where n is an integer representing a portion of the remaining space when shared.
    ]]
    resultsPage0.Rows("3*", "2*")

    
    --[[
        Create a new DataGrid (for showing a 1D or 2D table of data)

        static dataGrid CreateDataGrid()

        where:
            - dataGrid is a new DataGrid object
    ]]
    grid0 = CreateDataGrid()

    --[[
        Add the grid to the page in the first row (0) and the second column (1)

        void resultsPage.AddChild(uiElement child [,int row, int col [, int rowSpan, int colSpan] ] ])

        where:
            - resultsPage: a ResultsPage object
            - child: a child UI element (at this time, a Chart or a DataGrid)
            - row: (optional) the row to place the child, default:0
            - col: (optional) the column to place the child, default:0
            - rowSpan: (optional) the number of rows the child spans across, default:1
            - colSpan: (optional) the number of columns the child spans across, default: 1
    ]]
    resultsPage0.AddChild(grid0, 0, 1, 2, 1)

    --[[
        Create a Cartesian chart for plotting the voltages real-time, during sampling

        static chart Chart.CreateCartesian()

        where:
            - chart: is a new CartesianChart object
            - Chart: is the global Chart object
    ]]  
    voltageChart = Chart.CreateCartesian()
    vc_y = voltageChart.CreateYAxis()
    vc_y.MinLimit = 10
    vc_y.MaxLimit = 20
    
    -- voltageChart.LegendPosition = Chart.LegendPosition.Right

    -- Create 14 series, one for each battery, and put them into the chart we created above
    BV_PS = {}
    for i=1,14 do
        --[[
            Create a point (x,y) data series in this chart

            series chart.CreatePointSeries([string name [, Chart.Color color [, number thickness] ] ])

            where:
                - series: a new PointSeries object
                - name: (optional) the name of the data series
                - color: (optional) the color of the data series line
                - thickness: (optional) the thickness of the data series line, default: 1
        ]]
        BV_PS[i]  = voltageChart.CreatePointSeries("BV"..i, Chart.Color.gray)
    end

    -- put the chart into the second page.  By default this goes into the first row (0) and first column (0)
    resultsPage0.AddChild(voltageChart)

    -- create chart for current and SOC
    currentSocChart = Chart.CreateCartesian()

    --[[
        Annotate the X-axis of the Current and SOC chart by adding an XAxis

        axis = chart.CreateXAxis(string name, Chart.Color color)

        where:
            - axis: a new axis object
            - chart: the chart to which the axis is applied
            - name: the name of the axis (ex:"time")
            - color: the color of the axis labels
    ]]
    currentSocChart.CreateXAxis("ElapsedTime")

    -- Create series for current and SOC
    CurrentSeries = currentSocChart.CreatePointSeries("Current", Chart.Color.Red)
    SocSeries = currentSocChart.CreatePointSeries("SOC", Chart.Color.blue)

    -- put currentSocChart on to resultsPage0
    resultsPage0.AddChild(currentSocChart, 1, 0)

    -- switch pages to the second page that we created, above.
    resultsPage0.NavigateTo()

    -- get ready to record discharge data
    DISCHARGES = {}
    DischargeSetIndex = 0
    LastCurrent = -1  -- Assume it's currently charging so we don't capture a mid-charge set
    LastSampleElapsedTime = 0
    CumAmpHours = 0

    --[[
        Strange, yes.  This is used to assure Sample won't be called before PreTest has completed
    ]]
    return 10
end

--[[
    Optional function called after vehicle has been sampled.

    table Sample(seconds, signals)
    
    where:
        - table: a table of processed signal variables (ShortNames and Values) that will be appended to the signals data and presented to the PostTest function
        - signals: the currently sampled OBD2 signals (1D table, including ElapsedTime and DateTime key-value-pairs)
]]

function Sample(signals)

    -- calculate battery voltages
    BV = 
    {
        [1] = (signals.BV_A * 256 + signals.BV_B) * 79.99 / 65535,
        [2] = (signals.BV_C * 256 + signals.BV_D) * 79.99 / 65535,
        [3] = (signals.BV_E * 256 + signals.BV_F) * 79.99 / 65535,
        [4] = (signals.BV_G * 256 + signals.BV_H) * 79.99 / 65535,
        [5] = (signals.BV_I * 256 + signals.BV_J) * 79.99 / 65535,
        [6] = (signals.BV_K * 256 + signals.BV_L) * 79.99 / 65535,
        [7] = (signals.BV_M * 256 + signals.BV_N) * 79.99 / 65535,
        [8] = (signals.BV_O * 256 + signals.BV_P) * 79.99 / 65535,
        [9] = (signals.BV_Q * 256 + signals.BV_R) * 79.99 / 65535,
        [10] = (signals.BV_S * 256 + signals.BV_T) * 79.99 / 65535,
        [11] = (signals.BV_U * 256 + signals.BV_V) * 79.99 / 65535,
        [12] = (signals.BV_W * 256 + signals.BV_X) * 79.99 / 65535,
        [13] = (signals.BV_Y * 256 + signals.BV_Z) * 79.99 / 65535,
        [14] = (signals.BV_AA * 256 + signals.BV_AB) * 79.99 / 65535,
    }

    -- add the data from this sample to the series used in the voltageChart
    for i=1,14 do
        BV_PS[i].Add(signals.ElapsedTime, BV[i]);
    end

    -- replace the data used to populate grid0 with the latest data
    local snapshot = {
        ElapsedTime = signals.ElapsedTime,
        Current = (signals.BI_A * 2.56 + signals.BI_B * 0.01) - 327.68,
        SOC = signals.SOC,
        CumAmpHours = CumAmpHours, 
        V_AuxBV = (signals.AuxB_A * 256 + signals.AuxB_B) * 79.9 / 65535 - 40,
        PwrResBV = (signals.PR_A * 256 + signals.PR_B) / 10,
        InletT = (signals.TB_In_A * 256 + signals.TB_In_B) / 256 - 50,
        TB1 = (signals.TB1_A * 256 + signals.TB1_B) / 256 - 50,
        TB2 = (signals.TB2_A * 256 + signals.TB2_B) / 256 - 50,
        TB3 = (signals.TB3_A * 256 + signals.TB3_B) / 256 - 50,
        IR1 = signals.IR_A, 
        IR2 = signals.IR_B, 
        IR3 = signals.IR_C, 
        IR4 = signals.IR_D, 
        IR5 = signals.IR_E, 
        IR6 = signals.IR_F, 
        IR7 = signals.IR_G, 
        IR8 = signals.IR_H, 
        IR9 = signals.IR_I, 
        IR10 = signals.IR_J, 
        IR11 = signals.IR_K, 
        IR12 = signals.IR_L, 
        IR13 = signals.IR_M, 
        IR14 = signals.IR_N, 
    }
    grid0.SetSource(snapshot)

    -- add data from this sample to the series used in the currentSocChart
    CurrentSeries.Add(signals.ElapsedTime, snapshot.Current)
    SocSeries.Add(signals.ElapsedTime, snapshot.SOC)

    local results = {}
    for k,v in pairs(snapshot) do
        results[k] = v
    end
    results.BV = BV


    -- record discharge data
    if (results.Current > 0) 
    then
        local AmpHours = (results.Current * (signals.ElapsedTime - LastSampleElapsedTime)/3600)

        -- put each discharge cycle into its own set of data
        if (LastCurrent < 0) 
        then
            AmpHours = 0
            CumAmpHours = 0
            DischargeSetIndex = DischargeSetIndex + 1
            --print ("DischargeSetIndex : " .. DischargeSetIndex)
            DISCHARGES[DischargeSetIndex] = {}
        end

        CumAmpHours = CumAmpHours + AmpHours

        table.insert(DISCHARGES[DischargeSetIndex], results)
    end

    LastCurrent = snapshot.Current;
    LastSampleElapsedTime = signals.ElapsedTime

    return results
end

--[[
    Optional function called after sampling has completed or has been stopped

    void PostTest(table sampleTimes, table samples)

    where:
        - sampleHistory: a table with all the samples signals (from OBD) and processed signals (returned from Sample function)
]]
function PostTest(sampleHistory)

    if (#DISCHARGES > 0)
    then
        LongestDischargeIndex = 0;
        LongestDischargeSet = {}

        -- which of the recorded discharge sets is the one with the most samples?
        for i,dischargeSet in ipairs(DISCHARGES) do
            if (TableCount(dischargeSet) > TableCount(LongestDischargeSet))
            then
                LongestDischargeIndex = i
                LongestDischargeSet = dischargeSet
            end
        end

        -- save the data from the longest discharge set to the spreadsheet
        PublishAsTab("LongestDischarge", LongestDischargeSet)
        -- Dump("LongestDischargeSet", LongestDischargeSet)

    else
        print(">> NO DISCHARGES RECORDED")
        return
    end



    -- 1) find the best 7 batteries in the longest discharge set

    -- Initialize memory
    local D_BV = {}
    for i1=1,8 do
        D_BV[i1] = {}
        for i2=i1+1,9 do
            D_BV[i1][i2] = {}
            for i3=i2+1,10 do
                D_BV[i1][i2][i3] = {}
                for i4=i3+1,11 do
                    D_BV[i1][i2][i3][i4] = {}
                    for i5=i4+1,12 do
                        D_BV[i1][i2][i3][i4][i5] = {}
                        for i6=i5+1,13 do
                            D_BV[i1][i2][i3][i4][i5][i6] = {}
                            for i7=i6+1,14 do
                                D_BV[i1][i2][i3][i4][i5][i6][i7] = 0
                            end
                        end
                    end
                end
            end
        end
    end

    -- calculate variance (times 7) for each regression of 7 battery voltages
    for _,v in ipairs(LongestDischargeSet) do
        for i1=1,8 do
            local s1 = v.BV[i1]
            for i2=i1+1,9 do
                local s2 = s1 + v.BV[i2]
                for i3=i2+1,10 do
                    local s3 = s2 + v.BV[i3]
                    for i4=i3+1,11 do
                        local s4 = s3 + v.BV[i4]
                        for i5=i4+1,12 do
                            local s5 = s4 + v.BV[i5]
                            for i6=i5+1,13 do
                                local s6 = s5 + v.BV[i6]
                                for i7=i6+1,14 do
                                    local s7 = s6 + v.BV[i7]
                                    local avg = s7 / 7
                                    local var7 = ((v.BV[i1]-avg)*(v.BV[i1]-avg)
                                        +(v.BV[i2]-avg)*(v.BV[i2]-avg)
                                        +(v.BV[i3]-avg)*(v.BV[i3]-avg)
                                        +(v.BV[i4]-avg)*(v.BV[i4]-avg)
                                        +(v.BV[i5]-avg)*(v.BV[i5]-avg)
                                        +(v.BV[i6]-avg)*(v.BV[i6]-avg)
                                        +(v.BV[i7]-avg)*(v.BV[i7]-avg))
                                    D_BV[i1][i2][i3][i4][i5][i6][i7] = D_BV[i1][i2][i3][i4][i5][i6][i7] + var7
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- find the 7 batteries with the lowest variance (relative to their average)
    local lowestDeviation = 32000000;
    for i1=1,8 do
        for i2=i1+1,9 do
            for i3=i2+1,10 do
                for i4=i3+1,11 do
                    for i5=i4+1,12 do
                        for i6=i5+1,13 do
                            for i7=i6+1,14 do
                                if (D_BV[i1][i2][i3][i4][i5][i6][i7] < lowestDeviation) then
                                    lowestDeviation = D_BV[i1][i2][i3][i4][i5][i6][i7]
                                    best7 = {i1,i2,i3,i4,i5,i6,i7}
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    print("--------- best7 indexes -------")
    Dump("best7", best7)


    -- 2) calculate average of best seven
    for i,v in ipairs(LongestDischargeSet) do
        local averageDischarge = 0
        for _,index in ipairs(best7) do
            averageDischarge = averageDischarge + v.BV[index]/7
        end
        v["Best7AvgDB"] = averageDischarge
    end

    -- 3) Plot LongestDischargeSet voltage discharge curves
    do
        LongestDischargeVoltageChart = Chart.CreateCartesian()
        local xAxis = LongestDischargeVoltageChart.CreateXAxis("Amp Hours")
        local PS_LDBD = {}
        for i=1,14 do
            PS_LDBD[i] = LongestDischargeVoltageChart.CreatePointSeries("BV"..i, Chart.Color.gray)
            if (TableContainsValue(best7, i)) then 
                PS_LDBD[i].strokeColor = Chart.Color.blue; 
            end
            for j,v in ipairs(LongestDischargeSet) do
                PS_LDBD[i].add(v.CumAmpHours, v.BV[i])
            end
        end
        local PS_LD_B7A = LongestDischargeVoltageChart.CreatePointSeries("B7_AVG", Chart.Color.green, 6)
        for i,v in ipairs(LongestDischargeSet) do
            PS_LD_B7A.add(v.CumAmpHours, v.Best7AvgDB)
        end
        local dischargePage = CreateResultsPage("Best Discharge", "")
        dischargePage.AddChild(LongestDischargeVoltageChart)
    end

    -- 4) Calculate and plot the relative (to Best7 avg) voltage discharge curves (and display cummalative errors in a table)
    do
        local LongestDischargeBest7AverageOffsetChart = Chart.CreateCartesian()
        local xAxis = LongestDischargeBest7AverageOffsetChart.CreateXAxis("Amp Hours")
        local PS_B7D_BV = {}
        local Error = {}
        for i=1,14 do
            Error[i] = 0
            PS_B7D_BV[i] = LongestDischargeBest7AverageOffsetChart.CreatePointSeries("B7_AVG_OFFSET_"..i, Chart.Color.gray)
            if (TableContainsValue(best7, i)) then 
                PS_B7D_BV[i].strokeColor = Chart.Color.blue; 
            end
            for j,v in ipairs(LongestDischargeSet) do
                Error[i] = Error[i] + (v.BV[i] - v.Best7AvgDB)*(v.BV[i] - v.Best7AvgDB)
                PS_B7D_BV[i].add(v.CumAmpHours, v.BV[i] - v.Best7AvgDB)
            end
        end
        local dischargeOffsetPage = CreateResultsPage("Best7 Discharge Offset", "")
        dischargeOffsetPage.Columns("*", "auto")
        dischargeOffsetPage.AddChild(LongestDischargeBest7AverageOffsetChart)
        local dischargeOffsetTable = CreateDataGrid()
        dischargeOffsetTable.SetSource(Error)
        dischargeOffsetPage.AddChild(dischargeOffsetTable,0,1)
    end

    -- 4) Calculate and Plot the discharge balance of each battery
    do
        BalanceAndSlope = {}
        local Balance = {}
        for i=1,14 do
            Balance[i] = 0
            BalanceAndSlope[i] = {}
            sampleCount = 0
            for j,v in ipairs(LongestDischargeSet) do
                sampleCount = sampleCount + 1
                Balance[i] = Balance[i] + v.BV[i] - v.Best7AvgDB
            end
            Balance[i] = Balance[i] / sampleCount
            BalanceAndSlope[i]["Battery"] = i
            BalanceAndSlope[i]["Balance"] = Balance[i]
        end
        balanceAndDischargeChart = Chart.CreateCartesian()
        CS_Balance = balanceAndDischargeChart.CreateColumnSeries("Balance (ΔV)", Chart.Color.Blue)
        CS_Balance.Add(Balance)
        local xAxis = balanceAndDischargeChart.CreateXAxis("Battery")
        xAxis.Labels = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }
        local balanceAndDischargePage = CreateResultsPage("Balance and Discharge", "")
        balanceAndDischargePage.AddChild(balanceAndDischargeChart)
    end

    -- 5) Calculate and plot the discharge slope of each battery
    do
        local CS_Slope = balanceAndDischargeChart.CreateColumnSeries("ΔV/ΔAmpHr", Chart.Color.Red)
        local x = {}
        local y = {}
        for i=1,14 do
            y[i] = {}
            for j,v in ipairs(LongestDischargeSet) do
                x[j] = v.CumAmpHours
                y[i][j] = v.BV[i] - v.Best7AvgDB
            end
            local m = Slope(x, y[i])
            BalanceAndSlope[i]["Slope"] = m
            CS_Slope.Add(m)
        end
    end
    
    -- 6) Add Balance and Slope to spreadsheet
    PublishAsTab("BalanceAndSlope", BalanceAndSlope)

end


--[[
    supporting function
]]

function Dump(name, variable)

    if (type(name) == "nil") then
        name = ""
    end

    if (type(variable) == "table") then
        for k,v in pairs(variable) do
            if (type(k) == "number") then
                Dump(name .. "[" .. k .. "]", v)
            else

                Dump(name .. "." .. k, v)
            end
        end
        return
    end

    if (type(variable) == "string" or type(variable) == "number") then
        print(name .. ": " .. variable)
        return
    end

    if (type(variable) == "boolean") then
        if (variable) then
            print(name .. ": true")
        else
            print(name .. ": false")
        end
        return
    end

    print(name .. ": dump of type [".. type(variable) .."] is not supported")

end

function NewBest7(best7set, candidateItem)
    -- make sure we don't already have this item
    indexes = {}
    for _,item in ipairs(best7set) do
        if (not hasValue(best7set, item.i)) then
            table.insert(indexes, item.i)
        end
        if (not hasValue(best7set, item.j)) then
            table.insert(indexes, item.j)
        end
    end

    if (hasValue(indexes, candidateItem.i) and hasValue(indexes, candidateItem.j)) then
        return false
    end
    
    --  is this item linked to the existing items?
    for _,item in ipairs(best7set) do
        if ((item.i == candidateItem.i) ~= (item.j == candidateItem.j)) then
            return true
        end
    end 
    return false
end

function hasValue(tbl, value)
    for k, v in ipairs(tbl) do -- iterate table (for sequential tables only)
        if v == value then -- Compare value from the table directly with the value we are looking for
            return true -- Found in this or nested table
        end
    end
    return false -- Not found
end

function TableCount(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
  end


  function TableContainsValue(table, value)
    for _,v in pairs(table) do
        if (v == value) then return true end
    end
    return false
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

function BoolToString(boolValue)
    if (boolValue) then
        return "true"
    else
        return "false"
    end
end
