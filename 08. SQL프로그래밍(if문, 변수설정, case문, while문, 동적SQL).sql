# 스토이드 프로시저는 MySQL에서 프로그래밍 기능이 필요할 때 사용하는 데이터베이스 개체이다.
-- SQL 프로그래밍은 기본적으로 스토어드 프로시저 안에 만들어야 한다.
/* 스토이드 프로시저의 구조
delimiter $$
create prcedure -- 스토이드_프로시저_이름()
begin
	-- 이 부분에 SQL 프로그래밍 코딩
END $$
delimiter; -- 종료문자를 다시 세미콜론으로 변경
call 스토어드_프로시저_이름(); -- 스토어드 프로시저 실행
*/

# IF문
/*
if <조건식> then
	SQL 문장들
end if;
*/
-- SQL 문장들이 두 문장 이상 처리되어야 할 때는 begin ~ end로 묶어줘야 한다.
-- ifProc1이 이미 있다면 삭제한다.
drop procedure if exists ifProc1;
-- 세미콜론으로는 스토이드_프로시저의 끝인지, SQL의 끝인지 모르기에 $$를 사용한다.
delimiter $$

create procedure ifProc1()
begin
	if 100 = 100 then
		select '100은 100과 같습니다.';
	end if;
end $$

delimiter ;
call ifProc1();

# if else문
drop procedure if exists ifProc2
delimiter $$
create procedure ifProc2()
begin
-- declare 예약어를 사용해서 myNum 변수지정
declare myNum int; 
set myNum = 200;
if myNum = 100 then select '100입니다.';
else select '100이 아닙니다.';
end if;
end $$
delimiter ;
call ifProc2();

# if 문의 활용
-- 아이디가 APN인 회원의 데뷔일자가 5년이 넘었는지 확인해보고 넘었으면 축하 메시지를 출력해보자
drop procedure if exists ifProc3;
delimiter $$
create procedure ifProc3()
begin
declare debutDate date; -- 데뷔 일자
declare curDate date; -- 오늘
declare days int; -- 활동한 일수
select debut_date into debutDate from market_db.member where mem_id = 'APN'; -- into를 사용하면 결과를 debutDate라는 변수에 저장한다.
set curDate = current_date(); -- 현재 날짜
set days = datediff(curDate, debutDate); -- 날짜의 차이, 일 단위
if (days/365) >= 5 then -- 5년이 지났다면
select concat('데뷔한지 ', days,'일이나 지났습니다. 축하합니다!' );
else select'데뷔한 지 ' + days + '일밖에 안되었군요.';
end if;
end $$
delimiter ;
call ifProc3;
-- 날짜 관련함수들
/*
current_date() -- 오늘 날짜를 알려줌
current_timestamp() -- 오늘 날짜 및 시간을 함께 알려준다.
datediff(날짜1, 날짜2) -- 날짜1 부터 날짜2 까지 일수로 몇 일인지 세어준다.
*/

# case문
-- if 문은 참, 거짓 두 가지만 있다.
-- case문은 2가지 이상의 여러가지 경우일 때 처리가 가능하다.
/*
case
when 조건1 then SQL문장1
when 조건2 then SQL문장2
when 조건3 then SQL문장3
else SQL문장4
end case;
*/
-- ex) 90점 이상은 a, 80점 이상은 b, 70점 이상은 c, 60점 이상은 d, 60점 미만은 f로 나누자.
drop procedure if exists caseproc;
delimiter $$
create procedure caseproc()
begin
declare point int;
declare credit char(1);
set point = 88;

case 
when point >= 90 then set credit = 'a';
when point >= 80 then set credit = 'b';
when point >= 70 then set credit = 'c';
when point >= 60 then set credit = 'd';
else set credit = 'f';
end case;
select concat('취득점수==>', point), concat('학점==>',credit);
end $$
delimiter ;
call caseproc();

# case 문의 활용
-- 회원들의 총 구매액을 계산해서 회원의 등급을 4단계로 나누자
-- 먼저 구매 테이블에서 회원별로 총 구매액을 구해보자
select mem_id, sum(price*amount) "총 구매액" from buy group by mem_id;
-- 구매액이 많은 순으로 정렬하자
select mem_id, sum(price*amount) "총 구매액" from buy group by mem_id order by sum(price*amount) desc;
-- 이번에는 회원 이름도 출력해봐, 회원 이름은 회원테이블에 있으므로 조인시켜 출력하자
select b.mem_id, m.mem_name, sum(price*amount) "총 구매액"
from buy b
inner join member m
on b.mem_id = m.mem_id
group by b.mem_id
order by sum(price*amount) desc;
-- 이번에는 구매하지 않은 회원의 아이디와 이름도 출력해보자
select m.mem_id, m.mem_name, sum(price*amount) "총구매액"
from buy b
right outer join member m
on b.mem_id = m.mem_id
group by m.mem_id
order by sum(price*amount) desc;
-- 이제 총 구매액에 따라 회원 등급을 구분해보자
select m.mem_id, m.mem_name, sum(price*amount) "총구매액",
case
when (sum(price*amount) >= 1500) then '최우수고객'
when (sum(price*amount) >= 1000) then '우수고객'
when (sum(price*amount) >= 1) then '일반고객'
else '유령고객'
end "회원등급"
from buy b
right outer join member m
on b.mem_id = m.mem_id
group by m.mem_id
order by sum(price*amount) desc;

# while 문
-- 필요한 만큼 같은 내용을 반복해준다.
-- 조건이 참인 동안에 SQL문장들을 계속 반복한다.
/*
while <조건식> do
SQL 문장들
end while;
*/
-- 1부터 100까지 값을 모두 더하는 간단한 기능을 while문으로 구현해보자
drop procedure if exists whileproc;
delimiter $$
create procedure whileproc()
begin
declare i int;
declare hap int;
set i = 1;
set hap = 0;

while (i <= 100) do
set hap = hap + i;
set i = i+1;
end while;
select  '1부터 100까지의 합==>',hap;
end $$
delimiter ;
call whileproc();

# while 문의 응용
-- 1에서 100까지의 합계에서 4의 배수를 제외시키려면 어떻게 해야할까? 즉 1+2+3+5+6+7+9...
-- 추가로 숫자를 더하는 중간에 합계가 1,000이 넘으면 더하는걸 그만두고 넘는순간의 숫자를 출력한후 프로그램을 종료하게 만들어보자
-- iterate : 지정한 레이블로가서 계속 진행한다.
-- leave : 지정한 레이블이 종료된다. 즉 while몬이 종료된다.
drop procedure if exists whileproc2;
delimiter $$
create procedure whileproc2()
begin 
declare i int;
declare hap int;
set i=1;
set hap=0;

mywhile:
while (i<=400) do
if (i%4 = 0) then
set i =i+1;
iterate mywhile;
end if;
set hap = hap + i;
if (hap>1000) then leave mywhile;
end if;
set i = i+1;
end while;

select '1부터 100까지의 값(4의 배수 제외), 1000 넘으면 종료 ==>', hap;
end$$
delimiter ;
call whileproc2();

# 동적 SQL
-- prepare : SQL문을 실행하지 않고 미리 준비만 해놓는다.
-- execute : 준비한 SQL문을 실행한다.
-- deallocate prepare : 문장을 해제한다.
use market_db;
prepare myQuery from 'select * from member where mem_id = "BLK"';
execute myQuery;
deallocate prepare myQuery;

# 동적 SQL의 활용
-- prepare문에서 ?로 향후에 입력될 값을 비워 놓고, execute에서 using으로 ?에 값을 전달할 수 있다.
-- ex) 출입문에서 출입증을 태그하는 순간 날짜와 시간이 insert문으로 만들어져서 입력되도록 해보자
drop table if exists gate_table;
create table gate_table (id int auto_increment primary key, entry_time datetime);
set @curdate = current_timestamp(); -- 현재 날짜와 시간
prepare myquery from 'insert into gate_table values(null, ?)';
execute myquery using @curdate;
deallocate prepare myquery;
select * from gate_table;

