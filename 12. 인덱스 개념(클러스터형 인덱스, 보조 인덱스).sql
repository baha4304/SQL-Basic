# 인덱스
-- 인덱스는 select를 사용해서 테이블을 조회할 때 결과를 빠르게 추출하도록 도와주는 기능이다.
-- 인덱스는 데이터를 빠르게 찾을 수 있도록 도와주는 도구로, 실무에서는 현실적으로 인덱스 없이 데이터베이스 운영이 불가하다.
-- 인덱스에는 클러스터형 인덱스와 보조 인덱스가 있다.

# 인덱스의 장점과 단점
## 장점
-- 적절한 인덱스를 생성하고 사용한다면 기존보다 아주 빠른 응답속도를 얻을 수 있다.
-- select문으로 검색하는 속도가 매우 빨라진다.
## 단점
-- 인덱스도 공간을 차지해서 데이터베이스 안에 추가적인 공간이 필요하다.

# 인덱스의 종류
-- 클러스터형 인덱스와 보조 인덱스
-- 클러스터형 인덱스 : 영어 사전처럼 책의 내용이 이미 알파벳 순서대로 정렬되어 있는 것.
-- 보조 인덱스 : 찾아보기가 별도로 있고, 찾아보기에서 해당 단어를 찾은 후에 옆에 표시된 페이지를 펼쳐야 실제 찾는 내용이 있는 것.
## 자동으로 생성되는 인덱스
-- 인덱스는 테이블의 열 단위에 생성되며, 하나의 열에는 하나의 인덱스를 생성할 수 있다.
-- member테이블을 정의할 때, mem_id를 기본 키로 정의했다. 
-- 이렇게 기본 키로 지정하면 자동으로 mem_id 열에 클러스터형 인덱스가 생성된다.
-- 간단한 테이블을 만들고 첫 번째 열을 기본키로 지정해보자
use market_db;
create table table1(
col1 int primary key,
col2 int,
col3 int
);
-- 이제 테이블의 인덱스를 확인해보자
show index from table1;
-- key_name부분에 primary라고 써있다. 이것은 기본 키로 설정해서 자동으로 생성된  인덱스라는 의미이다.
-- 이것이 클러스터형 인덱스이다(key_name에 primary라고 써있다면 클러스터형 인덱스라고 생각하면 된다).
-- 기본 키와 더불어 고유 키도 인덱스가 자동으로 생성된다. 이렇게 생성된 인덱스는 보조 인덱스라고 부른다.
use market_db;
create table table2(
col1 int primary key,
col2 int unique,
col3 int unique
);
show index from table2;
-- key_name에 col2, col3로 열 이름이 써 있다. 이렇게 열 이름이 써있는 것은 보조 인덱스라고 생각하면 된다.
## 자동으로 정렬되는 클러스터형 인덱스
-- 클러스터형 인덱스는 기본 키로 지정하면 자동 생성된다는 것을 알았다. 그리고 테이블에 1개만 생성되는 것도 배웠다.
-- 또한 해당 인덱스의 열의 데이터들은 알파벳 순으로 자동 정렬된다.
use market_db;
drop table if exists buy,member;
create table member(
mem_id char(8),
mem_name varchar(10),
mem_number int,
addr char(2)
);
-- 데이터를 몇 건 입력하고 확인해보면 결과는 입력한 순서대로 나올 것이다.
insert into member values('TWC','트와이스',9,'서울');
insert into member values('BLK','블랙핑크',4,'경남');
insert into member values('WMN','여자친구',6,'경기');
insert into member values('OMY','오마이걸',7,'서울');
select * from member;
-- 이제 mem_id열을 기본 키로 설정하고 결과를 보면, 알파벳 순으로 데이터테이블이 바뀌었을 것이다.
alter table member
add constraint primary key(mem_id);
select *from member;
-- 이번에는 mem_name열을 primary key로 지정해보자, 한국어를 기준으로 정렬될 것이다.
alter table member drop primary key; -- primary key 제거
alter table member add constraint primary key(mem_name);
select * from member;
-- 지금부터 데이터를 추가하면 알아서 기준에 맞춰 정렬한다.
insert into member values('GRL','소녀시대',8,'서울');
select * from member;
## 자동 정렬기능이 없는 보조 인덱스
-- 보조 인덱스를 만든다고 해서, 테이블의 순서나 내용이 바뀌지 않는다.
-- 실습을 위해서 회원 테이블의 열을 고유키 없이 몇 개 만들어보자
drop table if exists member;
create table member(
mem_id char(8),
mem_name varchar(10),
mem_number int,
addr char(2)
);
-- 데이터를 몇 건 입력하고 확인해보면 결과는 입력한 순서대로 나올 것이다.
insert into member values('TWC','트와이스',9,'서울');
insert into member values('BLK','블랙핑크',4,'경남');
insert into member values('WMN','여자친구',6,'경기');
insert into member values('OMY','오마이걸',7,'서울');
select * from member;
-- 이제 mem_id 열을 고유키로 설정하고 내용을 살펴보자
alter table member add constraint unique(mem_id);
select * from member;
-- 보조 인덱스를 생성해도 데이터의 내용이나 순서는 변경되지 않는다.
-- 이번에는 mem_name 열에 추가로 고유키를 지정해보자
alter table member add constraint unique(mem_name);
select * from member;
-- 순서가 바뀌지 않는다.
-- 데이터를 추가로 입력하면, 본문 제일 뒤에 추가된다.
insert into member values('GRL','소녀시대',8,'서울');
-- 보조 인덱스는 여러 개를 만들 수 있다.
-- 하지만 만들 때마다 데이터베이스의 공간을 차지하게 되고, 전반적으로 시스템에 오히려 나쁜 영향을 미친다.



