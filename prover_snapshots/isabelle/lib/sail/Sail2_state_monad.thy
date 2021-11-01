chapter \<open>Generated by Lem from \<open>../../src/gen_lib/sail2_state_monad.lem\<close>.\<close>

theory "Sail2_state_monad" 

imports
  Main
  "LEM.Lem_pervasives_extra"
  "Sail2_instr_kinds"
  "Sail2_values"

begin 

\<comment> \<open>\<open>open import Pervasives_extra\<close>\<close>
\<comment> \<open>\<open>open import Sail2_instr_kinds\<close>\<close>
\<comment> \<open>\<open>open import Sail2_values\<close>\<close>

\<comment> \<open>\<open> 'a is result type \<close>\<close>

type_synonym memstate =" (nat, memory_byte) Map.map "
type_synonym tagstate =" (nat, bitU) Map.map "
\<comment> \<open>\<open> type regstate = map string (vector bitU) \<close>\<close>

record 'regs sequential_state =
  
 regstate ::" 'regs " 

     memstate ::" memstate " 

     tagstate ::" tagstate " 


\<comment> \<open>\<open>val init_state : forall 'regs. 'regs -> sequential_state 'regs\<close>\<close>
definition init_state  :: \<open> 'regs \<Rightarrow> 'regs sequential_state \<close>  where 
     \<open> init_state regs = (
  (| regstate = regs,
     memstate = Map.empty,
     tagstate = Map.empty |) )\<close> 
  for  regs  :: " 'regs "


datatype 'e ex =
    Failure " string "
  | Throw " 'e "

datatype( 'a, 'e) result =
    Value " 'a "
  | Ex " ( 'e ex)"

\<comment> \<open>\<open> State, nondeterminism and exception monad with result value type 'a
   and exception type 'e. \<close>\<close>
type_synonym( 'regs, 'a, 'e) monadS =" 'regs sequential_state \<Rightarrow> ( ('a, 'e)result * 'regs sequential_state) set "

\<comment> \<open>\<open>val returnS : forall 'regs 'a 'e. 'a -> monadS 'regs 'a 'e\<close>\<close>
definition returnS  :: \<open> 'a \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set \<close>  where 
     \<open> returnS a s = ( {(Value a,s)})\<close> 
  for  a  :: " 'a " 
  and  s  :: " 'regs sequential_state "


\<comment> \<open>\<open>val bindS : forall 'regs 'a 'b 'e. monadS 'regs 'a 'e -> ('a -> monadS 'regs 'b 'e) -> monadS 'regs 'b 'e\<close>\<close>
definition bindS  :: \<open>('regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set)\<Rightarrow>('a \<Rightarrow> 'regs sequential_state \<Rightarrow>(('b,'e)result*'regs sequential_state)set)\<Rightarrow> 'regs sequential_state \<Rightarrow>(('b,'e)result*'regs sequential_state)set \<close>  where 
     \<open> bindS m f (s :: 'regs sequential_state) = (
  \<Union> (Set.image ((\<lambda>x .  
  (case  x of   (Value a, s') => f a s' | (Ex e, s') => {(Ex e, s')} ))) (m s)))\<close> 
  for  m  :: " 'regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set " 
  and  f  :: " 'a \<Rightarrow> 'regs sequential_state \<Rightarrow>(('b,'e)result*'regs sequential_state)set " 
  and  s  :: " 'regs sequential_state "


\<comment> \<open>\<open>val seqS: forall 'regs 'b 'e. monadS 'regs unit 'e -> monadS 'regs 'b 'e -> monadS 'regs 'b 'e\<close>\<close>
definition seqS  :: \<open>('regs sequential_state \<Rightarrow>(((unit),'e)result*'regs sequential_state)set)\<Rightarrow>('regs sequential_state \<Rightarrow>(('b,'e)result*'regs sequential_state)set)\<Rightarrow> 'regs sequential_state \<Rightarrow>(('b,'e)result*'regs sequential_state)set \<close>  where 
     \<open> seqS m n = ( bindS m ( (\<lambda>x .  
  (case  x of (_ :: unit) => n ))))\<close> 
  for  m  :: " 'regs sequential_state \<Rightarrow>(((unit),'e)result*'regs sequential_state)set " 
  and  n  :: " 'regs sequential_state \<Rightarrow>(('b,'e)result*'regs sequential_state)set "


\<comment> \<open>\<open>val chooseS : forall 'regs 'a 'e. SetType 'a => list 'a -> monadS 'regs 'a 'e\<close>\<close>
definition chooseS  :: \<open> 'a list \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set \<close>  where 
     \<open> chooseS xs s = ( List.set (List.map ((\<lambda> x .  (Value x, s))) xs))\<close> 
  for  xs  :: " 'a list " 
  and  s  :: " 'regs sequential_state "


\<comment> \<open>\<open>val readS : forall 'regs 'a 'e. (sequential_state 'regs -> 'a) -> monadS 'regs 'a 'e\<close>\<close>
definition readS  :: \<open>('regs sequential_state \<Rightarrow> 'a)\<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set \<close>  where 
     \<open> readS f = ( ((\<lambda> s .  returnS (f s) s)))\<close> 
  for  f  :: " 'regs sequential_state \<Rightarrow> 'a "


\<comment> \<open>\<open>val updateS : forall 'regs 'e. (sequential_state 'regs -> sequential_state 'regs) -> monadS 'regs unit 'e\<close>\<close>
definition updateS  :: \<open>('regs sequential_state \<Rightarrow> 'regs sequential_state)\<Rightarrow> 'regs sequential_state \<Rightarrow>(((unit),'e)result*'regs sequential_state)set \<close>  where 
     \<open> updateS f = ( ((\<lambda> s .  returnS ()  (f s))))\<close> 
  for  f  :: " 'regs sequential_state \<Rightarrow> 'regs sequential_state "


\<comment> \<open>\<open>val failS : forall 'regs 'a 'e. string -> monadS 'regs 'a 'e\<close>\<close>
definition failS  :: \<open> string \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set \<close>  where 
     \<open> failS msg s = ( {(Ex (Failure msg), s)})\<close> 
  for  msg  :: " string " 
  and  s  :: " 'regs sequential_state "


\<comment> \<open>\<open>val choose_boolS : forall 'regval 'regs 'a 'e. unit -> monadS 'regs bool 'e\<close>\<close>
definition choose_boolS  :: \<open> unit \<Rightarrow> 'regs sequential_state \<Rightarrow>(((bool),'e)result*'regs sequential_state)set \<close>  where 
     \<open> choose_boolS _ = ( chooseS [False, True])\<close>

definition undefined_boolS  :: \<open> unit \<Rightarrow>('c,(bool),'a)monadS \<close>  where 
     \<open> undefined_boolS = ( choose_boolS )\<close>


\<comment> \<open>\<open>val exitS : forall 'regs 'e 'a. unit -> monadS 'regs 'a 'e\<close>\<close>
definition exitS  :: \<open> unit \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set \<close>  where 
     \<open> exitS _ = ( failS (''exit''))\<close>


\<comment> \<open>\<open>val throwS : forall 'regs 'a 'e. 'e -> monadS 'regs 'a 'e\<close>\<close>
definition throwS  :: \<open> 'e \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set \<close>  where 
     \<open> throwS e s = ( {(Ex (Throw e), s)})\<close> 
  for  e  :: " 'e " 
  and  s  :: " 'regs sequential_state "


\<comment> \<open>\<open>val try_catchS : forall 'regs 'a 'e1 'e2. monadS 'regs 'a 'e1 -> ('e1 -> monadS 'regs 'a 'e2) ->  monadS 'regs 'a 'e2\<close>\<close>
definition try_catchS  :: \<open>('regs sequential_state \<Rightarrow>(('a,'e1)result*'regs sequential_state)set)\<Rightarrow>('e1 \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e2)result*'regs sequential_state)set)\<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e2)result*'regs sequential_state)set \<close>  where 
     \<open> try_catchS m h s = (
  \<Union> (Set.image ((\<lambda>x .  
  (case  x of
        (Value a, s') => returnS a s'
    | (Ex (Throw e), s') => h e s'
    | (Ex (Failure msg), s') => {(Ex (Failure msg), s')}
  ))) (m s)))\<close> 
  for  m  :: " 'regs sequential_state \<Rightarrow>(('a,'e1)result*'regs sequential_state)set " 
  and  h  :: " 'e1 \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e2)result*'regs sequential_state)set " 
  and  s  :: " 'regs sequential_state "


\<comment> \<open>\<open>val assert_expS : forall 'regs 'e. bool -> string -> monadS 'regs unit 'e\<close>\<close>
definition assert_expS  :: \<open> bool \<Rightarrow> string \<Rightarrow> 'regs sequential_state \<Rightarrow>(((unit),'e)result*'regs sequential_state)set \<close>  where 
     \<open> assert_expS exp1 msg = ( if exp1 then returnS ()  else failS msg )\<close> 
  for  exp1  :: " bool " 
  and  msg  :: " string "


\<comment> \<open>\<open> For early return, we abuse exceptions by throwing and catching
   the return value. The exception type is "either 'r 'e", where "Right e"
   represents a proper exception and "Left r" an early return of value "r". \<close>\<close>
type_synonym( 'regs, 'a, 'r, 'e) monadRS =" ('regs, 'a, ( ('r, 'e)sum)) monadS "

\<comment> \<open>\<open>val early_returnS : forall 'regs 'a 'r 'e. 'r -> monadRS 'regs 'a 'r 'e\<close>\<close>
definition early_returnS  :: \<open> 'r \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,(('r,'e)sum))result*'regs sequential_state)set \<close>  where 
     \<open> early_returnS r = ( throwS (Inl r))\<close> 
  for  r  :: " 'r "


\<comment> \<open>\<open>val catch_early_returnS : forall 'regs 'a 'e. monadRS 'regs 'a 'a 'e -> monadS 'regs 'a 'e\<close>\<close>
definition catch_early_returnS  :: \<open>('regs sequential_state \<Rightarrow>(('a,(('a,'e)sum))result*'regs sequential_state)set)\<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set \<close>  where 
     \<open> catch_early_returnS m = (
  try_catchS m
    ((\<lambda>x .  (case  x of   Inl a => returnS a | Inr e => throwS e ))))\<close> 
  for  m  :: " 'regs sequential_state \<Rightarrow>(('a,(('a,'e)sum))result*'regs sequential_state)set "


\<comment> \<open>\<open> Lift to monad with early return by wrapping exceptions \<close>\<close>
\<comment> \<open>\<open>val liftRS : forall 'a 'r 'regs 'e. monadS 'regs 'a 'e -> monadRS 'regs 'a 'r 'e\<close>\<close>
definition liftRS  :: \<open>('regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set)\<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,(('r,'e)sum))result*'regs sequential_state)set \<close>  where 
     \<open> liftRS m = ( try_catchS m ((\<lambda> e .  throwS (Inr e))))\<close> 
  for  m  :: " 'regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set "


\<comment> \<open>\<open> Catch exceptions in the presence of early returns \<close>\<close>
\<comment> \<open>\<open>val try_catchRS : forall 'regs 'a 'r 'e1 'e2. monadRS 'regs 'a 'r 'e1 -> ('e1 -> monadRS 'regs 'a 'r 'e2) ->  monadRS 'regs 'a 'r 'e2\<close>\<close>
definition try_catchRS  :: \<open>('regs sequential_state \<Rightarrow>(('a,(('r,'e1)sum))result*'regs sequential_state)set)\<Rightarrow>('e1 \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,(('r,'e2)sum))result*'regs sequential_state)set)\<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,(('r,'e2)sum))result*'regs sequential_state)set \<close>  where 
     \<open> try_catchRS m h = (
  try_catchS m
    ((\<lambda>x .  (case  x of   Inl r => throwS (Inl r) | Inr e => h e ))))\<close> 
  for  m  :: " 'regs sequential_state \<Rightarrow>(('a,(('r,'e1)sum))result*'regs sequential_state)set " 
  and  h  :: " 'e1 \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,(('r,'e2)sum))result*'regs sequential_state)set "


\<comment> \<open>\<open>val maybe_failS : forall 'regs 'a 'e. string -> maybe 'a -> monadS 'regs 'a 'e\<close>\<close>
definition maybe_failS  :: \<open> string \<Rightarrow> 'a option \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set \<close>  where 
     \<open> maybe_failS msg = ( (\<lambda>x .  
  (case  x of   Some a => returnS a | None => failS msg )))\<close> 
  for  msg  :: " string "


\<comment> \<open>\<open>val read_tagS : forall 'regs 'a 'e. Bitvector 'a => 'a -> monadS 'regs bitU 'e\<close>\<close>
definition read_tagS  :: \<open> 'a Bitvector_class \<Rightarrow> 'a \<Rightarrow>('regs,(bitU),'e)monadS \<close>  where 
     \<open> read_tagS dict_Sail2_values_Bitvector_a addr = ( bindS
  (maybe_failS (''nat_of_bv'') (nat_of_bv 
  dict_Sail2_values_Bitvector_a addr)) ((\<lambda> addr . 
  readS ((\<lambda> s .  case_option B0 id ((tagstate   s) addr))))))\<close> 
  for  dict_Sail2_values_Bitvector_a  :: " 'a Bitvector_class " 
  and  addr  :: " 'a "


\<comment> \<open>\<open> Read bytes from memory and return in little endian order \<close>\<close>
\<comment> \<open>\<open>val get_mem_bytes : forall 'regs. nat -> nat -> sequential_state 'regs -> maybe (list memory_byte * bitU)\<close>\<close>
definition get_mem_bytes  :: \<open> nat \<Rightarrow> nat \<Rightarrow> 'regs sequential_state \<Rightarrow>(((bitU)list)list*bitU)option \<close>  where 
     \<open> get_mem_bytes addr sz s = (
  (let addrs = (genlist ((\<lambda> n .  addr + n)) sz) in  
  (let read_byte = ((\<lambda> s addr .  (memstate   s) addr)) in
  (let read_tag = ((\<lambda> s addr .  case_option B0 id
                                          ( (tagstate   s) addr))) in
  map_option
    ((\<lambda> mem_val .  (mem_val, List.foldl and_bit B1
                                       (List.map (read_tag s) addrs))))
    (just_list (List.map (read_byte s) addrs))))))\<close> 
  for  addr  :: " nat " 
  and  sz  :: " nat " 
  and  s  :: " 'regs sequential_state "


\<comment> \<open>\<open>val read_memt_bytesS : forall 'regs 'e. read_kind -> nat -> nat -> monadS 'regs (list memory_byte * bitU) 'e\<close>\<close>
definition read_memt_bytesS  :: \<open> read_kind \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow>('regs,((memory_byte)list*bitU),'e)monadS \<close>  where 
     \<open> read_memt_bytesS _ addr sz = ( bindS
  (readS (get_mem_bytes addr sz))
  (maybe_failS (''read_memS'')))\<close> 
  for  addr  :: " nat " 
  and  sz  :: " nat "


\<comment> \<open>\<open>val read_mem_bytesS : forall 'regs 'e. read_kind -> nat -> nat -> monadS 'regs (list memory_byte) 'e\<close>\<close>
definition read_mem_bytesS  :: \<open> read_kind \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow>('regs,((memory_byte)list),'e)monadS \<close>  where 
     \<open> read_mem_bytesS rk addr sz = ( bindS
  (read_memt_bytesS rk addr sz) ( (\<lambda>x .  
  (case  x of (bytes, _) => returnS bytes ))))\<close> 
  for  rk  :: " read_kind " 
  and  addr  :: " nat " 
  and  sz  :: " nat "


\<comment> \<open>\<open>val read_memtS : forall 'regs 'e 'a 'b. Bitvector 'a, Bitvector 'b => read_kind -> 'a -> integer -> monadS 'regs ('b * bitU) 'e\<close>\<close>
definition read_memtS  :: \<open> 'a Bitvector_class \<Rightarrow> 'b Bitvector_class \<Rightarrow> read_kind \<Rightarrow> 'a \<Rightarrow> int \<Rightarrow>('regs,('b*bitU),'e)monadS \<close>  where 
     \<open> read_memtS dict_Sail2_values_Bitvector_a dict_Sail2_values_Bitvector_b rk a sz = ( bindS
  (maybe_failS (''nat_of_bv'') (nat_of_bv 
  dict_Sail2_values_Bitvector_a a)) ((\<lambda> a .  bindS
  (read_memt_bytesS rk a (nat_of_int sz)) ( (\<lambda>x .  
  (case  x of
      (bytes, tag) => bindS
                        (maybe_failS (''bits_of_mem_bytes'')
                           ((of_bits_method   dict_Sail2_values_Bitvector_b)
                              (bits_of_mem_bytes bytes)))
                        ((\<lambda> mem_val .  returnS (mem_val, tag)))
  ))))))\<close> 
  for  dict_Sail2_values_Bitvector_a  :: " 'a Bitvector_class " 
  and  dict_Sail2_values_Bitvector_b  :: " 'b Bitvector_class " 
  and  rk  :: " read_kind " 
  and  a  :: " 'a " 
  and  sz  :: " int "


\<comment> \<open>\<open>val read_memS : forall 'regs 'e 'a 'b 'addrsize. Bitvector 'a, Bitvector 'b => read_kind -> 'addrsize -> 'a -> integer -> monadS 'regs 'b 'e\<close>\<close>
definition read_memS  :: \<open> 'a Bitvector_class \<Rightarrow> 'b Bitvector_class \<Rightarrow> read_kind \<Rightarrow> 'addrsize \<Rightarrow> 'a \<Rightarrow> int \<Rightarrow>('regs,'b,'e)monadS \<close>  where 
     \<open> read_memS dict_Sail2_values_Bitvector_a dict_Sail2_values_Bitvector_b rk addr_size a sz = ( bindS
  (read_memtS dict_Sail2_values_Bitvector_a dict_Sail2_values_Bitvector_b rk a sz) ( (\<lambda>x .  
  (case  x of (bytes, _) => returnS bytes ))))\<close> 
  for  dict_Sail2_values_Bitvector_a  :: " 'a Bitvector_class " 
  and  dict_Sail2_values_Bitvector_b  :: " 'b Bitvector_class " 
  and  rk  :: " read_kind " 
  and  addr_size  :: " 'addrsize " 
  and  a  :: " 'a " 
  and  sz  :: " int "


\<comment> \<open>\<open>val excl_resultS : forall 'regs 'e. unit -> monadS 'regs bool 'e\<close>\<close>
definition excl_resultS  :: \<open> unit \<Rightarrow>('regs,(bool),'e)monadS \<close>  where 
     \<open> excl_resultS = (
  \<comment> \<open>\<open> TODO: This used to be more deterministic, checking a flag in the state
     whether an exclusive load has occurred before.  However, this does not
     seem very precise; it might be safer to overapproximate the possible
     behaviours by always making a nondeterministic choice. \<close>\<close>
  undefined_boolS )\<close>


\<comment> \<open>\<open> Write little-endian list of bytes to given address \<close>\<close>
\<comment> \<open>\<open>val put_mem_bytes : forall 'regs. nat -> nat -> list memory_byte -> bitU -> sequential_state 'regs -> sequential_state 'regs\<close>\<close>
definition put_mem_bytes  :: \<open> nat \<Rightarrow> nat \<Rightarrow>((bitU)list)list \<Rightarrow> bitU \<Rightarrow> 'regs sequential_state \<Rightarrow> 'regs sequential_state \<close>  where 
     \<open> put_mem_bytes addr sz v tag s = (
  (let addrs = (genlist ((\<lambda> n .  addr + n)) sz) in
  (let a_v = (List.zip addrs v) in  
  (let write_byte = ((\<lambda>mem p .  (case  (mem ,p ) of
                                            ( mem , (addr, v) ) => map_update
                                                                    addr 
                                                                   v 
                                                                   mem
                                        ))) in
  (let write_tag = ((\<lambda> mem addr .  map_update addr tag mem)) in
  ( s (| memstate := (List.foldl write_byte (memstate   s) a_v),
  tagstate := (List.foldl write_tag (tagstate   s) addrs) |)))))))\<close> 
  for  addr  :: " nat " 
  and  sz  :: " nat " 
  and  v  :: "((bitU)list)list " 
  and  tag  :: " bitU " 
  and  s  :: " 'regs sequential_state "


\<comment> \<open>\<open>val write_memt_bytesS : forall 'regs 'e. write_kind -> nat -> nat -> list memory_byte -> bitU -> monadS 'regs bool 'e\<close>\<close>
definition write_memt_bytesS  :: \<open> write_kind \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow>(memory_byte)list \<Rightarrow> bitU \<Rightarrow>('regs,(bool),'e)monadS \<close>  where 
     \<open> write_memt_bytesS _ addr sz v t = ( seqS
  (updateS (put_mem_bytes addr sz v t))
  (returnS True))\<close> 
  for  addr  :: " nat " 
  and  sz  :: " nat " 
  and  v  :: "(memory_byte)list " 
  and  t  :: " bitU "


\<comment> \<open>\<open>val write_mem_bytesS : forall 'regs 'e. write_kind -> nat -> nat -> list memory_byte -> monadS 'regs bool 'e\<close>\<close>
definition write_mem_bytesS  :: \<open> write_kind \<Rightarrow> nat \<Rightarrow> nat \<Rightarrow>(memory_byte)list \<Rightarrow> 'regs sequential_state \<Rightarrow>(((bool),'e)result*'regs sequential_state)set \<close>  where 
     \<open> write_mem_bytesS wk addr sz v = ( write_memt_bytesS wk addr sz v B0 )\<close> 
  for  wk  :: " write_kind " 
  and  addr  :: " nat " 
  and  sz  :: " nat " 
  and  v  :: "(memory_byte)list "


\<comment> \<open>\<open>val write_memtS : forall 'regs 'e 'a 'b. Bitvector 'a, Bitvector 'b =>
  write_kind -> 'a -> integer -> 'b -> bitU -> monadS 'regs bool 'e\<close>\<close>
definition write_memtS  :: \<open> 'a Bitvector_class \<Rightarrow> 'b Bitvector_class \<Rightarrow> write_kind \<Rightarrow> 'a \<Rightarrow> int \<Rightarrow> 'b \<Rightarrow> bitU \<Rightarrow> 'regs sequential_state \<Rightarrow>(((bool),'e)result*'regs sequential_state)set \<close>  where 
     \<open> write_memtS dict_Sail2_values_Bitvector_a dict_Sail2_values_Bitvector_b wk addr sz v t = (
  (case  (nat_of_bv dict_Sail2_values_Bitvector_a addr, mem_bytes_of_bits 
  dict_Sail2_values_Bitvector_b v) of
      (Some addr, Some v) => write_memt_bytesS wk addr (nat_of_int sz) v t
    | _ => failS (''write_mem'')
  ))\<close> 
  for  dict_Sail2_values_Bitvector_a  :: " 'a Bitvector_class " 
  and  dict_Sail2_values_Bitvector_b  :: " 'b Bitvector_class " 
  and  wk  :: " write_kind " 
  and  addr  :: " 'a " 
  and  sz  :: " int " 
  and  v  :: " 'b " 
  and  t  :: " bitU "


\<comment> \<open>\<open>val write_memS : forall 'regs 'e 'a 'b 'addrsize. Bitvector 'a, Bitvector 'b =>
  write_kind -> 'addrsize -> 'a -> integer -> 'b -> monadS 'regs bool 'e\<close>\<close>
definition write_memS  :: \<open> 'a Bitvector_class \<Rightarrow> 'b Bitvector_class \<Rightarrow> write_kind \<Rightarrow> 'addrsize \<Rightarrow> 'a \<Rightarrow> int \<Rightarrow> 'b \<Rightarrow> 'regs sequential_state \<Rightarrow>(((bool),'e)result*'regs sequential_state)set \<close>  where 
     \<open> write_memS dict_Sail2_values_Bitvector_a dict_Sail2_values_Bitvector_b wk addr_size addr sz v = ( write_memtS 
  dict_Sail2_values_Bitvector_a dict_Sail2_values_Bitvector_b wk addr sz v B0 )\<close> 
  for  dict_Sail2_values_Bitvector_a  :: " 'a Bitvector_class " 
  and  dict_Sail2_values_Bitvector_b  :: " 'b Bitvector_class " 
  and  wk  :: " write_kind " 
  and  addr_size  :: " 'addrsize " 
  and  addr  :: " 'a " 
  and  sz  :: " int " 
  and  v  :: " 'b "


\<comment> \<open>\<open>val read_regS : forall 'regs 'rv 'a 'e. register_ref 'regs 'rv 'a -> monadS 'regs 'a 'e\<close>\<close>
definition read_regS  :: \<open>('regs,'rv,'a)register_ref \<Rightarrow> 'regs sequential_state \<Rightarrow>(('a,'e)result*'regs sequential_state)set \<close>  where 
     \<open> read_regS reg = ( readS ((\<lambda> s . (read_from   reg)(regstate   s))))\<close> 
  for  reg  :: "('regs,'rv,'a)register_ref "


\<comment> \<open>\<open> TODO
let read_reg_range reg i j state =
  let v = slice (get_reg state (name_of_reg reg)) i j in
  [(Value (vec_to_bvec v),state)]
let read_reg_bit reg i state =
  let v = access (get_reg state (name_of_reg reg)) i in
  [(Value v,state)]
let read_reg_field reg regfield =
  let (i,j) = register_field_indices reg regfield in
  read_reg_range reg i j
let read_reg_bitfield reg regfield =
  let (i,_) = register_field_indices reg regfield in
  read_reg_bit reg i \<close>\<close>

\<comment> \<open>\<open>val read_regvalS : forall 'regs 'rv 'e.
  register_accessors 'regs 'rv -> string -> monadS 'regs 'rv 'e\<close>\<close>
fun read_regvalS  :: \<open>(string \<Rightarrow> 'regs \<Rightarrow> 'rv option)*(string \<Rightarrow> 'rv \<Rightarrow> 'regs \<Rightarrow> 'regs option)\<Rightarrow> string \<Rightarrow>('regs,'rv,'e)monadS \<close>  where 
     \<open> read_regvalS (read, _) reg = ( bindS
  (readS ((\<lambda> s .  read reg(regstate   s)))) ((\<lambda>x .  
  (case  x of
        Some v => returnS v
    | None => failS ((''read_regvalS '') @ reg)
  ))))\<close> 
  for  read  :: " string \<Rightarrow> 'regs \<Rightarrow> 'rv option " 
  and  reg  :: " string "


\<comment> \<open>\<open>val write_regvalS : forall 'regs 'rv 'e.
  register_accessors 'regs 'rv -> string -> 'rv -> monadS 'regs unit 'e\<close>\<close>
fun write_regvalS  :: \<open>(string \<Rightarrow> 'regs \<Rightarrow> 'rv option)*(string \<Rightarrow> 'rv \<Rightarrow> 'regs \<Rightarrow> 'regs option)\<Rightarrow> string \<Rightarrow> 'rv \<Rightarrow>('regs,(unit),'e)monadS \<close>  where 
     \<open> write_regvalS (_, write1) reg v = ( bindS
  (readS ((\<lambda> s .  write1 reg v(regstate   s)))) ((\<lambda>x .  
  (case  x of
        Some rs' => updateS ((\<lambda> s .  ( s (| regstate := rs' |))))
    | None => failS ((''write_regvalS '') @ reg)
  ))))\<close> 
  for  write1  :: " string \<Rightarrow> 'rv \<Rightarrow> 'regs \<Rightarrow> 'regs option " 
  and  reg  :: " string " 
  and  v  :: " 'rv "


\<comment> \<open>\<open>val write_regS : forall 'regs 'rv 'a 'e. register_ref 'regs 'rv 'a -> 'a -> monadS 'regs unit 'e\<close>\<close>
definition write_regS  :: \<open>('regs,'rv,'a)register_ref \<Rightarrow> 'a \<Rightarrow> 'regs sequential_state \<Rightarrow>(((unit),'e)result*'regs sequential_state)set \<close>  where 
     \<open> write_regS reg v = (
  updateS ((\<lambda> s .  ( s (| regstate := ((write_to   reg) v(regstate   s)) |)))))\<close> 
  for  reg  :: "('regs,'rv,'a)register_ref " 
  and  v  :: " 'a "


\<comment> \<open>\<open> TODO
val update_reg : forall 'regs 'rv 'a 'b 'e. register_ref 'regs 'rv 'a -> ('a -> 'b -> 'a) -> 'b -> monadS 'regs unit 'e
let update_reg reg f v state =
  let current_value = get_reg state reg in
  let new_value = f current_value v in
  [(Value (), set_reg state reg new_value)]

let write_reg_field reg regfield = update_reg reg regfield.set_field

val update_reg_range : forall 'regs 'rv 'a 'b. Bitvector 'a, Bitvector 'b => register_ref 'regs 'rv 'a -> integer -> integer -> 'a -> 'b -> 'a
let update_reg_range reg i j reg_val new_val = set_bits (reg.is_inc) reg_val i j (bits_of new_val)
let write_reg_range reg i j = update_reg reg (update_reg_range reg i j)

let update_reg_pos reg i reg_val x = update_list reg.is_inc reg_val i x
let write_reg_pos reg i = update_reg reg (update_reg_pos reg i)

let update_reg_bit reg i reg_val bit = set_bit (reg.is_inc) reg_val i (to_bitU bit)
let write_reg_bit reg i = update_reg reg (update_reg_bit reg i)

let update_reg_field_range regfield i j reg_val new_val =
  let current_field_value = regfield.get_field reg_val in
  let new_field_value = set_bits (regfield.field_is_inc) current_field_value i j (bits_of new_val) in
  regfield.set_field reg_val new_field_value
let write_reg_field_range reg regfield i j = update_reg reg (update_reg_field_range regfield i j)

let update_reg_field_pos regfield i reg_val x =
  let current_field_value = regfield.get_field reg_val in
  let new_field_value = update_list regfield.field_is_inc current_field_value i x in
  regfield.set_field reg_val new_field_value
let write_reg_field_pos reg regfield i = update_reg reg (update_reg_field_pos regfield i)

let update_reg_field_bit regfield i reg_val bit =
  let current_field_value = regfield.get_field reg_val in
  let new_field_value = set_bit (regfield.field_is_inc) current_field_value i (to_bitU bit) in
  regfield.set_field reg_val new_field_value
let write_reg_field_bit reg regfield i = update_reg reg (update_reg_field_bit regfield i)\<close>\<close>

\<comment> \<open>\<open> TODO Add Show typeclass for value and exception type \<close>\<close>
\<comment> \<open>\<open>val show_result : forall 'a 'e. result 'a 'e -> string\<close>\<close>
definition show_result  :: \<open>('a,'e)result \<Rightarrow> string \<close>  where 
     \<open> show_result = ( (\<lambda>x .  
  (case  x of
        Value _ => (''Value ()'')
    | Ex (Failure msg) => (''Failure '') @ msg
    | Ex (Throw _) => (''Throw'')
  )))\<close>


\<comment> \<open>\<open>val prerr_results : forall 'a 'e 's. SetType 's => set (result 'a 'e * 's) -> unit\<close>\<close>
definition prerr_results  :: \<open>(('a,'e)result*'s)set \<Rightarrow> unit \<close>  where 
     \<open> prerr_results rs = (
  (let _ = (Set.image ( (\<lambda>x .  
  (case  x of (r, _) => (let _ = (prerr_endline (show_result r)) in () ) ))) rs) in
  () ))\<close> 
  for  rs  :: "(('a,'e)result*'s)set "

end