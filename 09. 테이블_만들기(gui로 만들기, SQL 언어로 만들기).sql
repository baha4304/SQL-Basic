# 테이블 만들기
-- 테이블은 표 형태로 구성된 2차원 구조로, 행과 열로 구성되어 있다.
-- 행은 로우나 레코드라고 부르며, 열은 컬럼 또는 필름이라고 부른다.

-- 데이터베이스부터 만들어주자
create database naver_db;
-- 먼저 회원테이블을 생성해보자
-- naver_db 데이터베이스를 확장해서 tables를 선택하고 오른쪽 버튼을 클릭한 후 create table을 선택한다.
-- 설계한 대로 테이블을 구성하고, apply를 눌러준다.
-- gui 에서는 네이버 쇼핑 db구성도에서의 기본키-외래키 관계를 선택할 수 없다.
-- 그래서 완전 apply 하기전에 코드를 약간 수정해야한다.
/* 아래를 추가한다.
foreign key(mem_id) references member(mem_id)
*/
-- member 테이블을 출력해서 내용을 채워넣자
select * from naver_db.member;
-- 다음으로 buy 테이블 내용을 채워보자
-- 현재  buy랑 member는 기본키-외래키로 연결되어 있는데 buy에 member에 없는 값을 입력할 수가 없다.
-- ex) 회원가입도 안했는데 사려고하는것이나 마찬기지이기 때문
select * from naver_db.buy;

# 이제 SQL로 테이블을 만들어보자
-- 앞서 실습한 데이터베이스를 없애고 다시 만들어보자
-- 데이터베이스부터 생성하자
drop database if exists naver_db;
create database naver_db;
-- 다음으로 회원 테이블을 만들어보자
use naver_db;
drop table if exists member;
create table member
(
mem_id char(8) not null primary key,
mem_name varchar(10) not null,
mem_number tinyint not null,
addr char(2) not null,
phone1 char(3) null,
phone2 char(8) null,
height tinyint unsigned null,
debut_date date null
);
-- 다음으로 구매 테이블도 만들어보자
drop table if exists buy;
create table buy(
num int auto_increment not null primary key,
mem_id char(8) not null,
prod_name char(6) not null,
group_name char(4) null,
price int unsigned not null,
amount smallint unsigned not null,
foreign key(mem_id) references member(mem_id)
);
-- 회원테이블에 3건의 데이터를 입력해보자
insert into member values('TWC', '트와이스',9,'서울','02','11111111',167,'2015-10-19');
insert into member values('BLK', '블랙핑크',4,'경남','055','22222222',163,'2016-8-8');
insert into member values('WMN', '여자친구',6,'경기','031','33333333',166,'2015-1-15');
-- 구매데이터를 입력해보자 / 이것도 마찬가지로 회원테이블에 없는 값을 입력하면 오류가 뜬다.
insert into buy values(null,'BLK','지갑',null,30,2);
insert into buy values(null,'BLK','맥북프로','디지털',1000,1);
insert into buy values(null,'APK','아이폰','디지털',200,1); -- 오류가 뜬다.



