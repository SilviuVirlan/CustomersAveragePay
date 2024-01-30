page 50101 "Customer Average Late Pay"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Customer Avg. Late Pay";

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
                field("Avearage for Year"; Rec."Avearage for Year")
                {
                    ApplicationArea = All;
                }
                field(AvgDaysToPay; Rec."Average Late Pay (days)")
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

    local procedure LoadData()
    var
        Cust: Record Customer;
        AccPer: Record "Accounting Period";
        i: Integer;
    begin
        Rec.DeleteAll();
        AccPer.SetRange("New Fiscal Year", true);
        if Cust.FindSet() then
            repeat
                if AccPer.FindSet() then
                    repeat
                        Rec.Init();
                        Rec."No." := Cust."No.";
                        Rec.Name := Cust.Name;
                        Rec."Avearage for Year" := Date2DMY(AccPer."Starting Date", 3);
                        Rec."Average Late Pay (days)" := InvoicePaymentDaysAverage(Cust."No.", AccPer."Starting Date", CalcDate('+1Y-1D', AccPer."Starting Date"));
                        Rec.Insert(true);
                        i := Rec.Count();
                    until AccPer.Next() = 0;
            until Cust.Next() = 0;
        Rec.FindFirst();
    end;

    procedure InvoicePaymentDaysAverage(CustomerNo: Code[20]; StartDate: Date; EndDate: Date): Decimal
    begin
        exit(Round(CalcInvPmtDaysAverage(CustomerNo, StartDate, EndDate), 1));
    end;

    local procedure CalcInvPmtDaysAverage(CustomerNo: Code[20]; StartDate: Date; EndDate: Date): Decimal
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        PaymentDays: Integer;
        InvoiceCount: Integer;
    begin
        CustLedgEntry.SetCurrentKey("Document Type", "Customer No.", Open);
        if CustomerNo <> '' then
            CustLedgEntry.SetRange("Customer No.", CustomerNo);
        CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
        CustLedgEntry.SetRange(Open, false);
        CustLedgEntry.SetFilter("Due Date", '%1..%2', StartDate, EndDate);
        if not CustLedgEntry.FindSet() then
            exit(0);

        repeat
            DetailedCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.");
            DetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgEntry."Entry No.");
            DetailedCustLedgEntry.SetRange("Document Type", DetailedCustLedgEntry."Document Type"::Payment);
            if DetailedCustLedgEntry.FindLast() then begin
                if DetailedCustLedgEntry."Posting Date" > CustLedgEntry."Due Date" then
                    PaymentDays += DetailedCustLedgEntry."Posting Date" - CustLedgEntry."Due Date";
                InvoiceCount += 1;
            end;
        until CustLedgEntry.Next() = 0;

        if InvoiceCount = 0 then
            exit(0);

        exit(PaymentDays / InvoiceCount);
    end;
}