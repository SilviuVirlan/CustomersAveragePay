table 50101 "Customer Avg. Late Pay"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Avearage for Year"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Average Late Pay (days)"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        myInt: Integer;
        _rec: Record "Customer Avg. Late Pay";
    begin
        if _rec.FindLast() then
            "Entry No." := _rec."Entry No." + 1
        else
            "Entry No." := 1;
    end;
}