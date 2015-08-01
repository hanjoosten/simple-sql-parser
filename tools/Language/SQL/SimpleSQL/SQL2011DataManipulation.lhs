
Section 14 in Foundation


> module Language.SQL.SimpleSQL.SQL2011DataManipulation (sql2011DataManipulationTests) where

> import Language.SQL.SimpleSQL.TestTypes
> import Language.SQL.SimpleSQL.Syntax

> sql2011DataManipulationTests :: TestItem
> sql2011DataManipulationTests = Group "sql 2011 data manipulation tests"
>     [


14 Data manipulation


14.1 <declare cursor>

<declare cursor> ::=
  DECLARE <cursor name> <cursor properties>
      FOR <cursor specification>

14.2 <cursor properties>

<cursor properties> ::=
  [ <cursor sensitivity> ] [ <cursor scrollability> ] CURSOR
      [ <cursor holdability> ]
      [ <cursor returnability> ]

<cursor sensitivity> ::=
    SENSITIVE
  | INSENSITIVE
  | ASENSITIVE

<cursor scrollability> ::=
    SCROLL
  | NO SCROLL

<cursor holdability> ::=
    WITH HOLD
  | WITHOUT HOLD

<cursor returnability> ::=
    WITH RETURN
  | WITHOUT RETURN

14.3 <cursor specification>

<cursor specification> ::=
  <query expression> [ <updatability clause> ]

<updatability clause> ::=
  FOR { READ ONLY | UPDATE [ OF <column name list> ] }

14.4 <open statement>

<open statement> ::=
  OPEN <cursor name>

14.5 <fetch statement>

<fetch statement> ::=
     FETCH [ [ <fetch orientation> ] FROM ] <cursor name> INTO <fetch target list>

<fetch orientation> ::=
    NEXT
  | PRIOR
  | FIRST
  | LAST
  | { ABSOLUTE | RELATIVE } <simple value specification>

<fetch target list> ::=
     <target specification> [ { <comma> <target specification> }... ]


14.6 <close statement>

<close statement> ::=
  CLOSE <cursor name>

14.7 <select statement: single row>

<select statement: single row> ::=
  SELECT [ <set quantifier> ] <select list>
      INTO <select target list>
      <table expression>

<select target list> ::=
  <target specification> [ { <comma> <target specification> }... ]

14.8 <delete statement: positioned>

<delete statement: positioned> ::=
     DELETE FROM <target table> [ [ AS ] <correlation name> ]
         WHERE CURRENT OF <cursor name>

<target table> ::=
    <table name>
  | ONLY <left paren> <table name> <right paren>

14.9 <delete statement: searched>

<delete statement: searched> ::=
  DELETE FROM <target table>
      [ FOR PORTION OF <application time period name>
        FROM <point in time 1> TO <point in time 2> ]
      [ [ AS ] <correlation name> ]
      [ WHERE <search condition> ]

>      (TestStatement SQL2011 "delete from t"
>      $ Delete [Name "t"] Nothing Nothing)

>     ,(TestStatement SQL2011 "delete from t as u"
>      $ Delete [Name "t"] (Just (Name "u")) Nothing)

>     ,(TestStatement SQL2011 "delete from t where x = 5"
>      $ Delete [Name "t"] Nothing
>        (Just $ BinOp (Iden [Name "x"]) [Name "="] (NumLit "5")))


>     ,(TestStatement SQL2011 "delete from t as u where u.x = 5"
>      $ Delete [Name "t"] (Just (Name "u"))
>        (Just $ BinOp (Iden [Name "u", Name "x"]) [Name "="] (NumLit "5")))

14.10 <truncate table statement>

<truncate table statement> ::=
  TRUNCATE TABLE <target table> [ <identity column restart option> ]

<identity column restart option> ::=
    CONTINUE IDENTITY
  | RESTART IDENTITY

>     ,(TestStatement SQL2011 "truncate table t"
>      $ Truncate [Name "t"] DefaultIdentityRestart)

>     ,(TestStatement SQL2011 "truncate table t continue identity"
>      $ Truncate [Name "t"] ContinueIdentity)

>     ,(TestStatement SQL2011 "truncate table t restart identity"
>      $ Truncate [Name "t"] RestartIdentity)


14.11 <insert statement>

<insert statement> ::=
  INSERT INTO <insertion target> <insert columns and source>

<insertion target> ::=
  <table name>

<insert columns and source> ::=
    <from subquery>
  | <from constructor>
  | <from default>

<from subquery> ::=
  [ <left paren> <insert column list> <right paren> ]
      [ <override clause> ]
      <query expression>

<from constructor> ::=
  [ <left paren> <insert column list> <right paren> ]
      [ <override clause> ]
      <contextually typed table value constructor>

<override clause> ::=
    OVERRIDING USER VALUE
  | OVERRIDING SYSTEM VALUE

<from default> ::=
  DEFAULT VALUES

<insert column list> ::=
  <column name list>

>     ,(TestStatement SQL2011 "insert into t select * from u"
>      $ Insert [Name "t"] Nothing
>        $ InsertQuery makeSelect
>          {qeSelectList = [(Star, Nothing)]
>          ,qeFrom = [TRSimple [Name "u"]]})

>     ,(TestStatement SQL2011 "insert into t(a,b,c) select * from u"
>      $ Insert [Name "t"] (Just [Name "a", Name "b", Name "c"])
>        $ InsertQuery makeSelect
>          {qeSelectList = [(Star, Nothing)]
>          ,qeFrom = [TRSimple [Name "u"]]})

>     ,(TestStatement SQL2011 "insert into t default values"
>      $ Insert [Name "t"] Nothing DefaultInsertValues)

>     ,(TestStatement SQL2011 "insert into t values(1,2)"
>      $ Insert [Name "t"] Nothing
>        $ InsertQuery $ Values [[NumLit "1", NumLit "2"]])

>     ,(TestStatement SQL2011 "insert into t values (1,2),(3,4)"
>      $ Insert [Name "t"] Nothing
>        $ InsertQuery $ Values [[NumLit "1", NumLit "2"]
>                               ,[NumLit "3", NumLit "4"]])

>     ,(TestStatement SQL2011
>       "insert into t values (default,null,array[],multiset[])"
>      $ Insert [Name "t"] Nothing
>        $ InsertQuery $ Values [[Iden [Name "default"]
>                                ,Iden [Name "null"]
>                                ,Array (Iden [Name "array"]) []
>                                ,MultisetCtor []]])


14.12 <merge statement>

<merge statement> ::=
  MERGE INTO <target table> [ [ AS ] <merge correlation name> ]
      USING <table reference>
      ON <search condition> <merge operation specification>

<merge correlation name> ::=
  <correlation name>

<merge operation specification> ::=
  <merge when clause>...

<merge when clause> ::=
    <merge when matched clause>
  | <merge when not matched clause>

<merge when matched clause> ::=
  WHEN MATCHED [ AND <search condition> ]
      THEN <merge update or delete specification>

<merge update or delete specification> ::=
    <merge update specification>
  | <merge delete specification>

<merge when not matched clause> ::=
  WHEN NOT MATCHED [ AND <search condition> ]
      THEN <merge insert specification>

<merge update specification> ::=
  UPDATE SET <set clause list>

<merge delete specification> ::=
  DELETE

<merge insert specification> ::=
  INSERT [ <left paren> <insert column list> <right paren> ]
      [ <override clause> ]
      VALUES <merge insert value list>

<merge insert value list> ::=
  <left paren>
      <merge insert value element> [ { <comma> <merge insert value element> }... ]
      <right paren>

<merge insert value element> ::=
    <value expression>
  | <contextually typed value specification>

14.13 <update statement: positioned>

<updatestatement: positioned> ::=
     UPDATE <target table> [ [ AS ] <correlation name> ]
         SET <set clause list>
         WHERE CURRENT OF <cursor name>

14.14 <update statement: searched>

<update statement: searched> ::=
  UPDATE <target table>
      [ FOR PORTION OF <application time period name>
        FROM <point in time 1> TO <point in time 2> ]
      [ [ AS ] <correlation name> ]
      SET <set clause list>
      [ WHERE <search condition> ]


>     ,(TestStatement SQL2011 "update t set a=b"
>      $ Update [Name "t"] Nothing
>        [Set [Name "a"] (Iden [Name "b"])] Nothing)

>     ,(TestStatement SQL2011 "update t set a=b, c=5"
>      $ Update [Name "t"] Nothing
>        [Set [Name "a"] (Iden [Name "b"])
>        ,Set [Name "c"] (NumLit "5")] Nothing)


>     ,(TestStatement SQL2011 "update t set a=b where a>5"
>      $ Update [Name "t"] Nothing
>        [Set [Name "a"] (Iden [Name "b"])]
>        $ Just $ BinOp (Iden [Name "a"]) [Name ">"] (NumLit "5"))


>     ,(TestStatement SQL2011 "update t as u set a=b where u.a>5"
>      $ Update [Name "t"] (Just $ Name "u")
>        [Set [Name "a"] (Iden [Name "b"])]
>        $ Just $ BinOp (Iden [Name "u",Name "a"])
>                       [Name ">"] (NumLit "5"))

>     ,(TestStatement SQL2011 "update t set (a,b)=(3,5)"
>      $ Update [Name "t"] Nothing
>        [SetMultiple [[Name "a"],[Name "b"]]
>                     [NumLit "3", NumLit "5"]] Nothing)



14.15 <set clause list>

<set clause list> ::=
  <set clause> [ { <comma> <set clause> }... ]

<set clause> ::=
    <multiple column assignment>
  | <set target> <equals operator> <update source>

<set target> ::=
    <update target>
  | <mutated set clause>

<multiple column assignment> ::=
  <set target list> <equals operator> <assigned row>

<set target list> ::=
  <left paren> <set target> [ { <comma> <set target> }... ] <right paren>

<assigned row> ::=
  <contextually typed row value expression>

<update target> ::=
    <object column>
  | <object column>
      <left bracket or trigraph> <simple value specification> <right bracket or trigraph>

<object column> ::=
  <column name>

<mutated set clause> ::=
  <mutated target> <period> <method name>

<mutated target> ::=
    <object column>
  | <mutated set clause>

<update source> ::=
    <value expression>
  | <contextually typed value specification>

14.16 <temporary table declaration>

<temporary table declaration> ::=
  DECLARE LOCAL TEMPORARY TABLE <table name> <table element list>
      [ ON COMMIT <table commit action> ROWS ]

14.17 <free locator statement>

<free locator statement> ::=
  FREE LOCATOR <locator reference> [ { <comma> <locator reference> }... ]

<locator reference> ::=
    <host parameter name>
  | <embedded variable name>
  | <dynamic parameter specification>

14.18 <hold locator statement>

<hold locator statement> ::=
  HOLD LOCATOR <locator reference> [ { <comma> <locator reference> }... ]


>    ]
