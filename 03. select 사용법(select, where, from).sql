# 데이터베이스만들기

# market_db를 삭제(책을 학습하다 market_db를 다시 실행할 일이 생기면 필요한 내용)
DROP DATABASE IF EXISTS market_db;
# market_db를 다시 실행하기
create database market_db;


# 회원테이블 만들기
-- use는 데이터베이스를 선택하는 문장이다.
USE market_db;
CREATE TABLE member -- 회원테이블(member)
(mem_id	char(8) not null primary key, -- 회원 아이디(PK)
mem_name	varchar(10) not null, -- 이름
mem_number	int not null, --  인원수
addr	char(2) not null, -- 주소(경기, 서울, 경남 식으로 2글자만 입력)
phone1	char(3), -- 연락처의 국번(02, 031, 055 .etc)
phone2	char(8), -- 연락처의 나머지 전화번호(하이픈제외)
height	smallint, -- 평균키
debut_date date -- 데뷔일자
);

# 구매 테이블 만들기
create table buy -- 구매테이블(buy)
(num	int auto_increment not null primary key, -- 순번(pk), auto_increment : 자동으로 숫자를 입력해준다.
mem_id	char(8)	not null, -- 아이디(FK)
prod_name	char(6)	not null, -- 제품 이름
group_name	char(4), -- 분류
price	int not null,-- 단가
amount smallint not null, -- 수량
foreign key (mem_id) references member(mem_id)
);

# 데이터 입력하기
insert into member values('TWC', '트와이스', 9, '서울', '02', '11111111',167,'2015.10.19');
insert into member values ('BLK','블랙핑크',4,'경남','055','22222222',163,'2016-08-08');
insert into buy values(NULL, 'BLK', '지갑', null, 30, 2); -- 구매 테이블의 첫 번째 열인 순번은 자동으로 입력되므로 null이라 써주면 된다.

# 데이터 조회하기
select * from member;
select * from buy;

# 기본 조회하기
# select문을 실행하려면 먼저 사용할 데이터베이스를 지정해야한다.
use market_db; -- market_db를 사용한다.
/*
select 열 이름
	[from 테이블 이름]
	[where 조건식]
	[group by 열_이름]
	[having 조건식]
	[oreder by 열_이름]
	[limit 숫자]
*/

# select와 from
use market_db;
-- member 테이블에서 모든 열의 내용을 가져와라
select * from member;
-- 원래 테이블의 전체 이름은 데이터베이스_이름.테이블_이름 형식으로 표현한다.
-- 그렇기에 원칙적으로는 다음과 같이 사용해야한다.
select * from market_db.member -- use문으로 미리 지정해놓으면 이렇게 할 필요 없이 생략해도 된다.

-- 이번에는 해당 테이블에서 전체 열이 아닌 필요한 열만 가져와본다
select mem_name from member;
-- 여러개의 열을 가져오고 싶다면, 콤마로 구분하면 된다.
select addr, debut_date, mem_name from member;

# where절
-- where은 조회하는 결과에 조건을 추가해서 원하는 데이터만 추출하는 것이다.
-- select 열이름 from 테이블이름 where 조건식
select * from member where mem_name = '블랙핑크';
select * from member where mem_number = 4;
select mem_id, mem_name from member where height <=162
select mem_name, height, mem_number from member where height >= 165 and mem_number >6;
select mem_name, height, mem_number from member where height >= 165 or mem_number >6;

select mem_name, height from member where height >= 163 and height <=165;
select mem_name, height from member where height between 163 and 165;
-- 경기 전남 경남 중 한 곳에 사는 회원 검색
select mem_name, addr from member where addr = '경기' or addr = '전남' or addr = '경남';
select mem_name, addr from member where addr in('경기', '전남', '경남');
-- 문자열의 일부 글자를 검색 / 이르므이 첫글자가 우로 시작하는 회원 검색 / 우 뒤에는 무엇이든(%) 허용한다.
select * from member where mem_name like '우%';
select * from member where mem_name like '%핑크';
-- 한 글자와 매칭하기 위해서는 언더바(_)를 사용한다.
select * from member where mem_name like '__핑크'; -- 언더바가 두개이므로 앞 두 글자는 상관없고 뒤는 핑크인 회원을 검색한다.

# 서브쿼리
-- select 안에는 또다른 select가 들어갈 수 있다. 이것을 서브쿼리라고 부른다.
-- ex) 이름이 에이핑크인 회원의 평균 키보다 큰 회원을 검색해보자
select mem_name, height from member where height > (select height from member where mem_name = '에이핑크');
