# 제약조건으로 테이블을 견고하게
-- 테이블을 만들 때는 테이블의 구조에 필요한 제약조건을 설정해줘야 한다.
-- 기본키-외래키가 대표적인 제약조건이다.
-- 기본키는 학번, 아이디, 사번 등과 같은 고유한 번호를 의미하는 열에, 외래키는 기본키와 연결되는 열에 저장한다.
-- 이메일과 휴대폰같이 중복되지 않는 열에는 '고유키'를 지정할 수 있다. 
-- 회원의 평균 키는 200cm를 넘지 않을 것이다. 이때 실수로 200을 입력하는 것을 방지하는 조건이 '체크'이다.
-- 회원 테이블에 국적을 입력한다면, 99%는 대한민국일 것이다. 매번 입력하기 귀찮다면 제약조건으로 '기본값'을 설정할 수 있다.
-- 또한 값을 꼭 입력해야 하는 not null 제약조건도 있다.

# 제약조건의 기본 개념과 종류
-- 제약조건 : 데이터의 무결성을 지키기 위해 제한하는 조건 / 무결성 : 데이터에 결함이 없음
-- 아이디가 중복되면 이메일, 블로그, 쇼핑 기록등 상당한 혼란이 야기될 것이다. 이러한 결함을 미리 방지하기 위해 회원 테이블의 아이디를 기본키로 지정할 수 있다.
/* 기본키 외에 MySQL에서 제공하는 대표적인 제약조건

primary key	제약조건
foreign key	제약조건
unique		제약조건
check		제약조건
default		정의
null 		값 허용
*/

# 기본키 제약조건
-- 테이블엔 많은 행 데이터가 있다.
-- 이 중에서 데이터를 구분할 수 있는 식별자를 기본키라고 부른다.
-- 기본키에 입력되는 값은 중복될 수 없으며, null 값이 입력될 수 없다.
-- 테이블은 기본키를 1개만 가질 수 있다.
-- create table에서 설정하는 기본키 제약조건
create database naver_db;
use naver_db;
create table member(
mem_id char(8) not null primary key,
mem_name varchar(10) not null,
height tinyint unsigned null
);
-- 이렇게 설정함으로써 회원 아이디는 회원테이블의 기본키가 되었으며, 앞으로 입력되는 회원 아이디는 중복될 수 없고, 비어 있을 수도 없다.
-- describe 문을 사용해서 테이블의 정보를 살펴보자
describe member;
-- create table에서 primary key를 지정하는 또 다른 방법
drop table if exists member;
create table member(
mem_id char(8) not null,
mem_name varchar(10) not null,
height tinyint unsigned null,
primary key(mem_id)
);
-- alter table에서 설정하는 기본 키 제약조건
-- 제약조건을 설정하는 또 다른 방법은 이미 만들어진 테이블을 수정하는 alter table 구문을 사용하는 것이다.
drop table if exists member;
create table member(
mem_id char(8) not null,
mem_name varchar(10) not null,
height tinyint unsigned null
);
-- add constraint : 제약조건을 추가한다.
alter table member
	add constraint
    primary key (mem_id);

# 외래키 제약조건
-- 외래키 제약조건은 두 테이블 사이의 관계를 연결해주고, 그 결과 데이터의 무결성을 보장해주는 역할을 한다.
-- 외래키가 설정된 열은 꼭 다른 테이블의 기본 키와 연결된다.
-- 여기서 기본키가 있는 테이블을 '기준 테이블'이라고 부르며, 외래키가 있는 구매 테이블을 '참조 테이블'이라고 부른다.
-- 또 하나 기억할 것은 참조 테이블이 참조하는 기준 테이블의 열은 반드시 기본키나 고유키로 설정되어야 한다.
-- create table에서 설정하는 외래키 제약조건
drop table if exists buy, member;
create table member(
mem_id char(8) not null primary key,
mem_name varchar(10) not null ,
height tinyint unsigned null
);
create table buy(
num int auto_increment not null primary key,
mem_id char(8) not null,
prod_name char(6) not null,
foreign key(mem_id) references member(mem_id)
);
-- 만약 기준테이블의 열이 primary key 또는 unique가 아니라면 외래 키 관계는 설정되지 않는다.
-- alter table에서 설정하는 외래 키 제약조건
drop table if exists buy;
create table buy(
num int auto_increment not null primary key,
mem_id char(8) not null,
prod_name char(6) not null
);
alter table buy
	add constraint
    foreign key(mem_id) references member(mem_id);
-- 기준테이블의 아이디를 변경하면 참조테이블의 아이디도 같이 변경될까?
-- 먼저 데이터를 채워넣어보자
insert into member values('BLK', '블랙핑크',163);
insert into buy values(null, 'BLK','지갑');
insert into buy values(null, 'BLK','맥북');
-- 내부 조인을 사용해서 물품 정보 및 사용자 정보를 확인해보자
select m.mem_id, m.mem_name, b.prod_name
from buy b
inner join member m
on b.mem_id = m.mem_id;
-- 이번에는 BLK를 PINK로 변경해보자
update member set mem_id = 'PINK' where mem_id = 'BLK';
-- 기본키-외래키로 맺어진 후에는 기준 테이블의 열 이름이 변경되지 않는다.
-- 기준 테이블의 열 이름이 변경될 때 참조 테이블의 열 이름도 자동으로 변경되게 하는 기능이 있다.
-- 바로 on update cascade이다. / on delete cascade문은 같이 삭제도 되게 하는 기능이다.
drop table if exists buy;
create table buy(
num int auto_increment not null primary key,
mem_id char(8) not null,
prod_name char(6) not null
);
alter table buy
	add constraint
    foreign key(mem_id) references member(mem_id)
    on update cascade
    on delete cascade;
-- 구매 테이블에 다시 데이터를 입력해보자.
insert into buy values(null, 'BLK','지갑');
insert into buy values(null, 'BLK','맥북');
-- 이제 회원 테이블의 BLK를 PINK로 변경해보자
update member set mem_id = 'PINK' where mem_id = 'BLK';
-- 이제 오류없이 잘 업데이트 된다. 
-- 다시 내부 조인을 사용해서 물품 정보 및 사용자 정보를 확인해보자
select m.mem_id, m.mem_name, b.prod_name
from buy b
inner join member m
on b.mem_id = m.mem_id;
-- 참조 테이블의 아이디가 모두 변경된 것을 확인할 수 있다.
-- 이번에는 PINK가 탈퇴한 것으로 가정하고 삭제해보자
delete from member where mem_id = 'PINK';
-- 구매 테이블의 데이터를 확인해보면 아무것도 없다.
select * from buy;

## 기타 제약조건

# 고유키 제약조건
-- 고유키 : 중복되지 않는 유일한 값을 입력해야하는 조건이다.
-- 이는 기본키 제약조건과 거의 비슷하지만, 고유키는 null값이 허용된다는 차이가 있다.
-- 만약 회원 테이블에 email 주소가 있다면 중복되지 않으므로 고유키로 설정할 수 있다.
drop table if exists buy, member;
create table member(
mem_id char(8) not null primary key,
mem_name varchar(10) not null,
height tinyint unsigned null,
email char(30) null unique
);
-- 데이터를 입력해보자
insert into member values('BLK', '블랙핑크',163, 'pink@gmail.com');
insert into member values('TWC', '트와이스',167,  NULL);
insert into member values('APN', '에이핑크',164, 'pink@gmail.com');
-- 같은 값이 들어가면 안되기에 오류가 뜬다.

# 체크 제약조건
-- 체크 제약조건 : 입력되는 데이터를 점검하는 기능
-- ex) 평균키에 마이너스 값이 입력되지 않게 하거나, 연락처 국번에 02,031,041,055 중 하나만 입력되도록 할 수 있다.
-- 먼저 테이블을 정의하면서, 평균키는 반드시 100이상의 값만 입력되도록 설정해보자
drop table if exists member;
create table member(
mem_id char(8) not null primary key,
mem_name varchar(10) not null,
height tinyint unsigned null check(height >= 100),
phone1 char(3) null
);
-- 데이터를 입력해보자, 두 번째 조건은 제약조건에 위배되므로 오류가 발생할 것이다.
insert into member values('BLK', '블랙핑크',163,  null);
insert into member values('TWC', '트와이스',99,  NULL);
-- 필요하다면 테이블을 만든 후에 alter table으로 제약조건을 추가해도 된다.
-- 연락처의 국번 phone1에 02,031,032,054,055,061 중 하나만 입력되도록 설정해보자
alter table member
	add constraint
    check(phone1 in ('02','031','032','054','055','061'));
-- 데이터를 입력해보자, 두 번째 조건은 제약조건에 위배되므로 오류가 발생할 것이다.
insert into member values('TWC', '트와이스',167,  '02');
insert into member values('OMY', '오마이걸',167,  '010');

# 기본값 정의
-- 기본값 정의 : 값을 입력하지 않았을 때 자동으로 입력될 값을 미리 지정해놓기
-- ex) 키를 입력하지 않으면 기본적으로 160으로 입력되게 하기
drop table if exists member;
create table member(
mem_id char(8) not null primary key,
mem_name varchar(10) not null,
height tinyint unsigned null default 160,
phone1 char(3) null
);
-- alter table 사용시 열에 default를 지정하기 위해서는 alter column문을 사용한다.
alter table member
	alter column phone1 set default'02';
-- 기본값이 설정된 열에 기본값을 입력하려면 default라고 써준다.
insert into member values('TWC', '트와이스',161,  '054');
insert into member values('OMY', '오마이걸',default,  default);
select * from member;
