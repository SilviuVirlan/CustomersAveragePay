page 50100 "Customer Average Pay"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Customer Average Pay";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec."Name")
                {
                    ApplicationArea = All;
                }
                field(AverageYear; Rec."Avearage for Year")
                {
                    ApplicationArea = All;
                    Caption = 'Averages for Year';
                }
                field(AvgDaysToPay; Rec."Average Days to Pay")
                {
                    ApplicationArea = All;
                    Caption = 'Average Days To Pay';
                }
            }
        }
        area(Factboxes)
        {

        }

    }

    actions
    {
        area(navigation)
        {
            group(Process)
            {
                Caption = 'Process';
                Image = Import;

                action("Reload Data")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reload Data';
                    Image = Import;

                    trigger OnAction()
                    begin
                        Rec.DeleteAll();
                        LoadData();
                        CurrPage.Update();
                    end;
                }
                action("Get Data")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Get Data';
                    Image = Import;

                    trigger OnAction()

                    begin
                        LoadData();
                        CurrPage.Update();
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.DeleteAll();
    end;

    procedure CustomAvgDaysToPay(CustNo: Code[20]; pYear: Integer): Decimal
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        CustLedgEntry2: Record "Cust. Ledger Entry";
        AvgDaysToPay: Decimal;
        TotalDaysToPay: Decimal;
        TotalNoOfInv: Integer;
        cuCustMgt: Codeunit "Customer Mgt.";
    begin
        with CustLedgEntry do begin
            AvgDaysToPay := 0;
            SetCurrentKey("Customer No.", "Posting Date");
            SetRange("Customer No.", CustNo);
            SetFilter("Posting Date", SetFilterForYear(pYear));
            SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
            SetRange(Open, false);

            if FindSet() then
                repeat
                    case true of
                        "Closed at Date" > "Posting Date":
                            UpdateDaysToPay("Closed at Date" - "Posting Date", TotalDaysToPay, TotalNoOfInv);
                        "Closed by Entry No." <> 0:
                            if CustLedgEntry2.Get("Closed by Entry No.") then
                                UpdateDaysToPay(CustLedgEntry2."Posting Date" - "Posting Date", TotalDaysToPay, TotalNoOfInv);
                        else begin
                            CustLedgEntry2.SetCurrentKey("Closed by Entry No.");
                            CustLedgEntry2.SetRange("Closed by Entry No.", "Entry No.");
                            if CustLedgEntry2.FindFirst() then
                                UpdateDaysToPay(CustLedgEntry2."Posting Date" - "Posting Date", TotalDaysToPay, TotalNoOfInv);
                        end;
                    end;
                until Next() = 0;
        end;

        if TotalNoOfInv <> 0 then
            AvgDaysToPay := TotalDaysToPay / TotalNoOfInv;

        exit(AvgDaysToPay);
    end;

    local procedure UpdateDaysToPay(NoOfDays: Integer; var TotalDaysToPay: Decimal; var TotalNoOfInv: Integer)
    begin
        TotalDaysToPay += NoOfDays;
        TotalNoOfInv += 1;
    end;

    procedure SetFilterForYear(pYear: Integer) pFilter: Text
    var
    begin
        pFilter := StrSubstNo('01/01/%1..12/31/%1', Format(pYear));
    end;


    local procedure LoadData()
    var
        Cust: Record Customer;
        CustMgt: Codeunit "Customer Mgt.";
        AccPer: Record "Accounting Period";
    begin
        AccPer.SetRange("New Fiscal Year", true);
        if Cust.FindSet() then
            repeat
                Rec.Init();
                Rec."No." := Cust."No.";
                Rec.Name := Cust.Name;
                if AccPer.FindSet() then
                    repeat
                        Rec."Avearage for Year" := Date2DMY(AccPer."Starting Date", 3);
                        Rec."Average Days to Pay" := CustomAvgDaysToPay(Cust."No.", Date2DMY(AccPer."Starting Date", 3));
                        Rec.Insert();
                    until AccPer.Next() = 0;
            until Cust.Next() = 0;
        Rec.FindFirst();
    end;



}