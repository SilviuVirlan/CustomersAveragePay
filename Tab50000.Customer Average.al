table 50100 "Customer Average Pay"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(10; "Avearage for Year"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Average Days to Pay"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "No.", "Avearage for Year")
        {
            Clustered = true;
        }
    }
}