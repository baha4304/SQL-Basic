# 데이터베이스와 테이블을 만든 후에는 데이터를 변경하는, 즉 입력/수정/삭제하는 기능이 필요하다.
-- 새로 가입한 회원을 테이블에 입력할 때는 insert문을
-- 정보가 변경되어 정보를 수정할 때는 update문을 
-- 정보를 삭제해야 할 때는 delete문을 사용한다.

# 데이터 입력 : insert
-- insert into 테이블 [(열1, 열2, ...)] values (값1, 값2, ...)
/* 주의할 점
테이블 이름 다음에 나오는 열은 생략이 가능하다, 
열 이름을 생략할 경우에 values 다음에 나오는 값들의 순서 및 개수는 테이블을 정의할 때의 열 순서 및 개수와 동일해야 한다.
*/
use market_db;
create table honggong (toy_id int, toy_name char(4), age int);
insert into honggong values (1, '우디', 25);
-- 만약 나이를 입력하고 싶지 않다면 테이블 이름 뒤에 열의 이름을 써줘야한다. / 이 경우 생략한 나이 값은 null값이 들어간다.
insert into honggong (toy_id, toy_name) values (1,'우디');
-- 열의 순서를 바꿔서 입력하고 싶다면, 열 이름과 값을 원하는 순서에 맞춰 써주면 된다.
insert into honggong (toy_name, age, toy_id) values ('제시', 20,3);

# 자동으로 증가하는 auto_increment
-- 열을 정의할 때 1부터 증가하는 값을 입력해준다. 
-- insert에서는 해당 열이 없다고 생각하고 입력하면된다.
-- 단, 주의할 점은 auto_increment로 지정하는 열은 꼭 primary key로 지정해줘야 한다.
create table honggong2 (toy_id int auto_increment primary key, toy_name char(4), age int);
insert into honggong2 values (null, '보핍', 25);
insert into honggong2 values (null, '슬링키', 22);
insert into honggong2 values (null, '렉스', 21);
-- 자동으로 숫자가 채워졌는지 확인해보자
select * from honggong2;
-- 계속 입력하다 보면 현재 어느 숫자까지 증가되었는지 확인이 필요하다 / 이는 자동증가로 몇 까지 입력되었는지 알려준다.
select last_insert_id()
-- 만약 auto_increment로 입력되는 다음 값을 100부터 시작하도록 변경하고 싶다면?
-- alter table : table을 변경하라 / 테이블의 열 이름 변경, 새로운 열 정의, 열 삭제 등의 작업을 한다.
alter table honggong2 auto_increment=100;
insert into honggong2 values (null, '재남',35);
select * from honggong2;
-- 처음부터 입력되는 값을 1000으로 지정하고 다음 값은 1003,1006, .. 으로 3씩 증가하도록 설정해보자
-- 이런 경우에는 시스템 변수인 @@auto_increment_increment를 변경해야한다.
create table honggong3 (toy_id int auto_increment primary key, toy_name char(4), age int);
alter table honggong3 auto_increment = 1000;
set @@auto_increment_increment = 3;
-- 증가값을 확인해보자
insert into honggong3 values (null, '토마스', 20);
insert into honggong3 values (null, '제임스', 23);
insert into honggong3 values (null, '고든', 25);
select * from honggong3;

# 다른 테이블의 데이터를 한 번에 입력하는 insert into ~ select
-- 다른 테이블에 이미 데이터가 입력되어 있다면 insert into ~ select 구문을 사용해 해당 테이블의 데이터를 가져와서 한 번에 입력할 수 있다.
-- insert into 테이블_이름 (열_이름1, 열_이름2, ...) select 문;
-- 먼저 mysql을 설치할 때 함께 생성된 world 데이터베이스의 city 테이블의 개수를 조회해보자
select count(*) from world.city; -- 4079개이다.
-- 이번에는 world.city 테이블의 구조를 살펴보자
desc world.city;
-- 데이터도 몇 건 살펴보자
select * from world.city limit 5;
-- 이중에서 도시 이름과 인구를 가져와보자 / 먼저 desc로 확인한 열이름과 데이터형식을 사용해서 테이블을 만들어보자
create table city_popul (city_name char(35), population int);
-- 이제 world.city 테이블의 내용을 city_popul 테이블에 입력해보자
insert into city_popul select Name, Population from world.city;

# 데이터 수정 : update
-- 행 데이터를 수정해야 하는 경우, update를 사용해서 내용을 수정한다.
/*
update 테이블_이름
	set 열1=값1, 열2, 값2, ...
    where 조건;
*/
-- MySQL 워크벤치에서는 기몬적으로 update 및 delete를 허용하지 않기 때문에 update를 실행하기 전에 설정을 변경해야 한다.
-- 이제, 앞에서 생성한 city_popul 테이블의 도시 이름 중에서 Seoul을 서울로 변경해보자
use market_db;
update city_popul set city_name = '서울' where city_name = 'Seoul';
select * from city_popul where city_name = '서울';
-- 필요하면 한꺼번에 여러 열의 값을 변경할 수도 있다.
-- 도시이름인 New York을 뉴욕으로 바꾸면서 동시에 인구는 0으로 설정해보자
update city_popul set city_name = '뉴욕', population = 0 where city_name = 'New York';
select * from city_popul where city_name = '뉴욕';
-- where가 없는 update문
-- where절은 문법상 생략이 가능하지만, 생략하면 테이블의 모든 행의 값이 변경된다.
-- update city_popul set city_name = '서울';
-- 다음 SQL을 이용해서 모든 인구 열을 한꺼번에 10,000으로 나눌 수 있다.
update city_popul set population = population / 10000;
select * from city_popul limit 5;

# 데이터 삭제
-- 테이블의 행 데이터를 삭제해야하는 경우도 발생한다. ex) 회원이 탈퇴했을 때
-- delete from 테이블이름 where 조건;
-- city_popul 테이블에서 new로 시작하는 도시를 삭제해보자
delete from city_popul where city_name like 'New%';
-- 만약 New글자로 시갖하는 도시를 모두 지우는 것이 아니라, 상위 몇 건만 삭제하려면 limit구문과 함께 쓰면된다.
delete from city_popul where city_name like 'New%' limit 5;

# 대용량 테이블의 삭제
-- 동일한 대용량 테이블 3개를 delete, drop, truncate 각각 다른 방법으로 삭제해보자
-- 먼저 각각 몇십만 데이터를 가진 테이블을 만들자
create table big_table1 (select * from world.city, sakila.country);
create table big_table2 (select * from world.city, sakila.country);
create table big_table3 (select * from world.city, sakila.country);
-- 우선 delete문은 삭제가 오래걸린다.
delete from big_table1;
-- drop문은 테이블 자체를 삭제하기에 빠르다.
drop table big_table2;
-- truncate 문도 delete문과 동일한 효과를 내지만 속도가 무척 뺘르다.
truncate table big_table3;
-- drop은 삭제후 테이블이 아예 안남지만 나머지 둘은 빈껍데기가 남는다.
