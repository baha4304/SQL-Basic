# 스토어드 함수
## 스토어드 함수의 개념과 형식
-- MySQL이 사용자가 원하는 모든 함수를 제공하지 않으므로 필요하다면 사용자가 직접 함수를 만들어서 사용할 수 있다.
/* 스토어드 함수는 다음과 같은 형식으로 구성할 수 있다.
delimiter $$
create function 스토어드_함수_이름(매개변수)
	returns 반환형식
begin
	이 부분에 프로그래밍 코딩
    return 반환값;

end $$
delimiter ;
select 스토어드_함수_이름();
*/

## 스토어드 함수의 사용
-- 스토어드 함수를 사용하기 위해서는 SQL로 스토어드 함수 생성 권한을 허용해줘야 한다.
set global log_bin_trust_function_creators = 1;
-- 먼저 간단한 스토어드 함수를 만들어서 사용해보자
-- 숫자 2개의 합계를 계산하는 스토어드 함수
use market_db;
drop function if exists sumFunc;
delimiter $$
create function sumFunc(number1 int, number2 int)
	returns int
begin
	return number1 + number2;
end $$
delimiter ;
select sumFunc(100,200) as '합계';
-- 이번에는 데뷔 연도를 입력하면, 활동 기간이 얼마나 되었는지 출력해주는 함수를 만들어보자
drop function if exists calcYearFunc;
delimiter $$
create function calcYearFunc(dYear int)
	returns int
begin 
	declare runYear int; -- 활동기간(연도)
	set runYear = YEAR(curdate()) - dYear;
    return runYear;
end $$
delimiter ;
select calcYearFunc(2010) as '활동 햇수';
-- 필요하다면 함수의 반환 값을 select ~ into ~로 저장했다가 사용할 수도 있다.
select calcYearFunc(2007) into @debut2007;
select @debut2007;

-- 함수는 주로 테이블을 조회한 후, 그 값을 계산할 때 사용한다. 
-- YEAR() : 연도만 추출해주는 함수
select YEAR('2025-04-21');
-- 회원 테이블에서 모든 회원이 데뷔한 지 몇 년이 되었는지 조회해 보자
select mem_id, mem_name, calcYearFunc(year(debut_date)) as '활동 햇수' from member;
-- 함수의 삭제는 drop function을 사용한다.
drop function calcYearFunc;


# 커서로 한 행씩 처리하기
-- 커서는 테이블에서 한 행씩 처리하기 위한 방식이다.
## 커서의 기본개념
-- 커서는 첫 번째 행을 처리한 후에 마지막 행까지 한 행씩 접근해서 값을 처리한다.
-- 커서는 대부분 스토어드 프로시저와 함께 사용된다. 
-- 커서의 세부 문법을 외우기보다는 커서를 사용하는 전반적인 흐름에 초점을 맞춰서 실습을 진행해보자
## 커서의 단계별 실습
-- 회원의 평균 인원수를 구하는 스토어드 프로시저를 작성해보자. 
/*
1. 사용할 변수 준비하기
회원의 평균 인원수를 계산하기 위해서 각 회원의 인원수(memNumber), 전체 인원의 합계(totNumber), 읽은 행의 수(cnt) 변수 3개를 준비한다.

전체 인원의 합계와 읽은 행의 수를 누적시켜야 하기 때문에 default문을 사용해 초기값을 0으로 설정했다

declare memNumber int;
declare cnt int default 0;
declare totNumber int default 0;
추가로 행의 끝을 파악하기 위한 변수 endOfRow를 준비하자, 처음에는 당연히 행의 끝이 아닐테니 false로 초기화 시켰다.
declare endOfRow boolean default false;
*/
/*
2. 커서 선언하기
이제 커서를 선언하자. 커서라는 것은 결국 select문이다. 
회원테이블(member)을 조회하는 구문을 커서로 만들어 놓으면 된다. memberCursor로 지정했다.

declare memberCursor cursor for select mem_number from member; 
*/
/*
3. 반복 조건 선언하기
이제는 행의 끝에 다다르면 앞에서 선언한 endOfRow 변수를 ture로 설정하자. 
delcare continue handler는 반복 조건을 준비하는 예약어이다.
그리고 for not found는 더 이상 행이 없을 때 이어진 문장을 수행한다.

declare continue handler
	for not found set endOfRow = true;
*/
/*
4. 커서 열기
앞에서 준비한 커서를 간단히 open으로 열면된다.

open memberCursor
*/
/*
5. 행 반복하기
커서의 끝까지 한 행씩 접근해서 반복할 차례이다.

cursor_loop : LOOP
	이 부분을 반복
end LOOP curosr_loop

그런데 이 코드는 무한 반복하기 때문에 코드 안에 반복문을 빠져나갈 조건이 필요하다.
leave는 반복할 이름을 빠져나간다. 결국 행의 끝에 다다르면 반복 조건을 선언한 3번에 의해서 endOfRow가 true로 변경되고 반복하는 부분을 빠져나가게 된다.

if endOfRow then 
	leave cursor_loop
end if;

이제 반복할 부분을 전체 표현해보자
fetch는 한 행씩 읽어오는 것이다. 2번에서 커서를 선언할 때 인원수 행을 조회했으므로 memnumber변수에는 각 회원의 인원수가 한 번에 하나씩 저장된다.
set 부분에서 읽은 행의 수(cnt)를 한씩 증가시키고, 인원수도 totNumber에 계속 누적시켰다.

cursor_loop : LOOP
	fetch memberCursor into memNumber;
    
    if endOfRow then
		leave cursor_loop;
	end if;
    
    set cnt = cnt + 1
    set totNumber = totNumber + memNumber;
end loop cursor_loop;

이제 반복을 빠져나오면 최종 목표였던 회원의 인원수를 계산한다. 누적된 총 인원수를 읽은 행의 수로 나누면 된다.

select (totNumber/cnt) as '회원의 평균 인원수'
*/
/*
6. 커서 닫기
모든작업이 끝났으면 커서를 닫는다.

close memberCursor;
*/
## 커서의 통합코드
use market_db;
drop procedure if exists cursor_proc;
delimiter $$
create procedure cursor_proc()
begin
	declare memNumber int;
    declare cnt int default 0;
    declare totNumber int default 0;
    declare endOfRow boolean default false;
    
    declare memberCursor cursor for select mem_number from member;
    
    declare continue handler for not found set endOfRow = true;
    
    open memberCursor;
    
    cursor_loop: loop
		fetch memberCursor into memNumber;
        
        if endOfRow then
			leave cursor_loop;
		end if;
        
        set cnt = cnt + 1;
        set totNumber = totNumber + memNumber;
	end loop cursor_loop;
    
    select (totNumber/cnt) as '회원의 평균 인원 수';
    
    close memberCursor;
end $$
delimiter ;
-- 이제 스토어드 프로시저를 실행해서 결과를 확인해보자
call cursor_proc();
























