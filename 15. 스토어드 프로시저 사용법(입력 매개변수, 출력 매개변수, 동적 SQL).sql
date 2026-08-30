# 스토어드 프로시저 사용방법
-- 스토어드 프로시저를 사용하면 MySQL안에서도 다른 프로그래밍 언어처럼 프로그램 로직의 코딩이 가능하다.

# 스토어드 프로시저 기본
-- 쿼리 문의 집합으로도 볼 수 있으며, 어떠한 동작을 일괄 처리하기 위한 용도로도 사용한다.
-- 자주 사용하는 일반적인 쿼리를 반복하는 것 보다는 스토어드 프로시저로 묶어 놓고 필요할 때마다 간단히 호출하는 것이 편리하다.
/* 스토어드 프로시저에서 가장 많이 사용되는 필수적인 형식
delimiter $$
create procedure 스토어드_프로시저_이름(in 또는 out 매개변수)
begin

	이 부분에 SQL 프로그래밍 코드를 작성
    
end $$
delimiter;
*/
-- 스토어드 프로시저를 호출하는 형식
-- call 스토어드_프로시저_이름();

## 스토어드 프로지서의 생성
use market_db;
drop procedure if exists user_proc;
delimiter $$
create procedure user_proc()
begin
	select * from member;
end $$
delimiter ;
call user_proc();

## 스토어드 프로시저의 삭제
drop procedure user_proc;

# 스토어드 프로시저 실습
-- 스토어드 프로시저에는 프로그래밍 기능을 사용하고 싶은 만큼 적용할 수 있다.
## 매개변수의 사용
/* 입력 매개변수 지정
in 입력_매개변수_이름 데이터_형식
*/
-- 입력 매개변수가 있는 스토어드 프로시저를 실행하기 위해서는 다음과 같이 값을 전달하면 된다.
/*
call 프로시저_이름(전달_값);
*/
/* 스토어드 프로시저에서 처리된 결과를 출력 매개변수를 통해 얻을 수도 있다.
out 출력_매개변수_이름 데이터_형식
*/
/* 출력 매개변수가 있는 스토어드 프로시저를 실행하기 위해서
call 프로시저_이름(@변수명);
select @변수명;
*/

## 입력 매개변수 활용
use market_db;
drop procedure if exists user_proc1;
delimiter $$
create procedure user_proc1(in userName varchar(10))
begin
	select * from member where mem_name = userName;
end $$
delimiter ;
-- call 을 통해 프로시저에 값을 넣고 출력
call user_proc1('에이핑크');
-- 이번에는 2개의 입력 매개변수가 있는 스토어드 프로시저를 만들어보자
drop procedure if exists user_proc2;
delimiter $$
create procedure user_proc2(in userNumber int, in userHeight int)
begin
	select * from member where mem_Number > userNumber and height > userHeight;
end $$
delimiter ;
call user_proc2(6,165);

## 출력 매개변수의 활용
-- 다음 스토어드 프로시저는 noTable이라는 이름의 테이블에 넘겨 받은 값을 입력하고, id 열의 최대 값을 알아내는 기능을 한다.
drop procedure if exists user_proc3;
delimiter $$
create procedure user_proc3(in txtValue char(10),
	out outValue int)
begin
	insert into noTable values(null, txtValue);
    select max(id) into outValue from noTable;
end $$
delimiter ;
-- 다음으로 noTable을 만들자
create table if not exists noTable(
	id int auto_increment primary key,
	txt char(10));
-- 스토어드 프로시저를 호출해보자
-- '텍스트1' 이란 값을 입력변수에 저장하고, myValue라는 변수에 출력변수값(outValue)를 저장 
call user_proc3('텍스트1', @myValue);
-- myValue라는 변수에 저장된 값을 출력 
SELECT CONCAT('입력된 id 값 --> ', @myValue);

# sql 프로그래밍의 활용
-- 조건문의 기본인 if ~ else문을 사용해보자
-- 가수 그룹의 데뷔연도가 2015년 이전이면 고참가수, 2015년 이후 이면 신인가수를 출력하는 스토어드 프로시저를 작성해보자
drop procedure if exists ifelse_porc;
delimiter $$
create procedure ifelse_proc(in memName varchar(10))
begin
	declare debutYear int; -- 변수 선언
    select year(debut_date) into debutYear from member where mem_name = memName;
    if (debutYear >= 2015) then
		select '신인 가수네요. 화이팅 하세요.' as '메시지';
	else 
		select '고참 가수네요. 그동안 수고하셨어요.' as '메시지';
	end if;
end $$
delimiter ;
call ifelse_proc('오마이걸');
-- 이번에는 여러번 반복하는 while문을 활용해보자
-- 1부터 100까지의 합계를 계산해보자
drop procedure if exists while_proc;
delimiter $$
create procedure while_proc()
begin 
	declare hap int; -- 합계
    declare num int; -- 1부터 100까지 증가
    set hap = 0;
    set num = 1;
    
    while (num <= 100) do
		set hap = hap + num;
        set num = num + 1;
	end while;
    select hap as '1~100 합계';
end $$
delimiter ;
call while_proc;
-- 마지막으로 동적 SQL을 활용해보자
-- 테이블 이름을 매개변수로 전달받아서 해당 테이블을 조회하자
drop procedure if exists dynamic_proc;
delimiter $$
create procedure dynamic_proc(in tableName varchar(20))
begin
	set @sqlQuery = concat('select * from ', tableName);
    prepare myQuery from @sqlQuery; -- @sqlQuery에 들어 있는 문자열을 SQL 명령으로 실행할 준비를 해라. 
    execute myQuery;
    deallocate prepare myQuery;
end $$
delimiter ;
call dynamic_proc('member');







 