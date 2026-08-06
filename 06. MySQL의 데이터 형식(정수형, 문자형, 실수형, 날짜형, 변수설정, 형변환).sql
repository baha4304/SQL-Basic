# MySQL의 데이터 형식
-- 데이터형식에 대한 이해가 밑바탕된다면, 효율적인 데이터 형식을 적절히 고를 수 있다.


# 정수형
-- 소수점이 없는 숫자, 즉 인원 수, 가격, 수량 등에 많이 사용된다.
/*
데이터 형식	바이트 수		숫자 범위
TINYINT		1			-128 ~ 127
SMALLINT	2			-32,768 ~ 32,767
INT			4			약 -21억 ~ +21억
BIGINT		8			약 -900경 ~ +900경
*/
-- 확인 차원에서 간단하게 테이블을 만들어보자
USE market_db;
create table honggong4(tinyint_col tinyint, smallint_col smallint, int_col int, biggint_col bigint);
-- 각 열의 최대값을 입력해보자
insert into honggong4 values(127,32767,2147483647,9000000000000000000);
-- 이제 1씩 더해서 입력해보자 / 적용이 안되는 모습이다.
insert into honggong4 values(128,32768,2147483648,90000000000000000000);
-- 모든 정수형은 -부터 +까지로 구성되어 있는데 unsigned 예약어를 이용하면 값의 범위를 0부터 시작시킬 수 있다.
-- ex) -128 ~ 127 이지만, tinyint unsigned를 쓰면 0 ~ 255 까지 입력가능

# 문자형
-- 글자를 저장하기 위해 사영하며, 입력할 최대 글자의 개수를 지정해야 한다.
/*
데이터 형식		바이트 수
CHAR(개수)		1 ~ 255
VARCHAR(개수) 	1 ~ 16383
*/
-- CHAR은 고정길이 문자형이다. / ex) CHAR(10)에 가나다 3글자만 저장해도 10자리를 모두 확보한 후에 앞에 3자리를 사용하고 뒤의 7자리는 낭비하게된다.
-- 이와 달리 VARCHAR은 가변길이 문자형으로 VARCHAR(10)에 3글자를 저장할 경우 3자리만 사용한다.
-- VARCHAR가 공간을 효율적으로 운영할 수 있지만, 성능(빠른 속도) 면에서는 CHAR로 설정하는 게 좋다.
-- 대량의 더 큰 데이터를 저장하려면?
/*
데이터 형식		바이트 수
TEXT			1 ~ 65535
LONGTEXT		1 ~ 4294967295
BLOB			1 ~ 65535          -- BLOB는 글자가 아닌 이미지나, 동영상 등의 데이터를 저장할 때 쓰인다.
LONGBLOB		1 ~ 4294967295(최대 약 4GB)
*/

# 실수형
-- 소수점이 있는 숫자를 저장할 때 사용한다.
/*
데이터 형식	바이트 수		설명
FLOAT		4			소수점 아래 7자리까지 표현
DOUBLE		8			소수점 아래 15자리까지 표현
*/

# 날짜형
-- 날짜 및 시간을 저장할 때 사용
/*
데이터 형식	바이트 수		설명
DATE		3			날짜만 저장, YYYY-MM-DD 형식으로 사용
TIME		3			시간만 저장, HH:MM:SS 형식으로 사용
DATETIME	8			날짜 및 시간을 저장, YYYY-MM-DD HH:MM:SS 형식으로 사용
*/
-- 날짜 또는 시간을 입력할 때는 문자와 마찬가지로 작은따옴표로 묶어줘야 한다.

# 변수의 사용
-- 변수 선언 방법
set @변수이름 = 변수의 값; -- 변수의 선언 및 값 대입
select @변수이름; -- 변수의 값 출력
-- ex)
use market_db;
-- 변수 선언 및 실수 대입
set @myvar1 = 5;
set @myvar2 = 4.25;
-- 변수의 내용 출력, 및 연산
select @myvar1;
select @myvar1 + @myvar2;
-- 변수 선언 및 문자열 또는 정수 대입
set @txt = '가수 이름==> ';
set @height = 166;
-- 테이블을 조회하며 변수를 활용
select @txt, mem_name from member where height > @height; 
-- select 문에서 limit에는 변수를 사용할 수 없다.
-- 이를 해결해주는 것이 prepare와 execute이다.
set @count = 3;
prepare mySQL from 'select mem_name, height from member order by height limit ?';
execute mySQL using @count;

# 데이터 형 변환
-- 문자형을 정수형으로 바꾸거나, 반대로 정수형을 문자형으로 바꾸는 것을 데이터의 형 변환이라고 부른다.
-- 변환에는 함수를 사용해서 변환하는 명시적 변환과, 별도의 지시없이 자연스럽게 변환되는 암시적인 변환이 있다.
-- 명시적 변환
/*
cast (값 as 데이터_형식 [(길이)])
convert (값, 데이터_형식 [(길이)])
*/
-- market_db의 구매 테이블에서 평균 가격을 구하는 SQL
select avg(price) as '평균 가격' from buy;
-- 결과가 실수값으로 나왔는데 이를 정수로 표현해보자
select cast(avg(price) as signed) '평균 가격' from buy; -- signed는 부호가 있는 정수, unsigned는 부호가 없는 정수를 의미한다.
-- 또는
select convert (avg(price), signed) '평균 가격' from buy;
-- 이번에는 날짜를 확인해보자
select cast('2022%12%12' as date);
select cast('2022/12/12' as date);
select cast('2022$12$12' as date);
select cast('2022@12@12' as date);
-- SQL 결과를 원하는 형태로 표현할 때도 사용할 수 있다. 
-- concat() : 문자를 이어주는 역할을 한다.
select num, concat(cast(price as char), ' x ', cast(amount as char), ' = ') '가격 x 수량', price * amount '구매액' from buy;
-- 암시적인 변환
-- 암시적인 변환은 cast나 convert함수를 사용하지 않고도 자연스럽게 형이 변환되는 것이다.
-- 문자는 서로 더할 수 없으므로 자동으로 숫자 100과 200으로 변환되어서 덧셈이 수행되었다.
select '100' + '200';
-- 만약 문자 100과 200을 연결한 100200으로 만들려면 concat을 이용하면 된다.
select concat('100', '200');

















