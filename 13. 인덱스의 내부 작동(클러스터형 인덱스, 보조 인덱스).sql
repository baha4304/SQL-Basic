# 인덱스의 내부 작동
-- 인덱스의 내부 작동 원리를 이해하면, 인덱스를 사용해야 할 경우와 사용하지 말아야 할 경우를 선택할 때 도움이 된다.

# 균형 트리의 개념
-- 균형 트리 구조에서 데이터가 저장되는 공간을 '노드'라고 한다.
-- 루트 노드 : 노드의 가장 상위 노드, 모든 출발은 루트 노드에서 시작된다. 
-- 리프 노드 : 제일 마지막에 존재하는 노드
-- 중간 노드 : 루트 노드와 리프 노드의 중간에 끼인 노드들
-- 노드라는 용어는 개념적 설명에서 주로 나오는 용어이며, MySQL에서는 페이지라고 부른다. 
-- 균형 트리는 SELECT구문을 사용할 때 아주 뛰어난 성능을 발휘한다. 

# 균형 트리의 페이지 분할
-- 인덱스는 SELECT구문, 즉 검색을 활용할 때는 성능이 좋지만, 데이터 변경 작업 시에는 성능이 나빠진다.
-- 특히 insert작업이 일어날 때 더 느리게 입력 될 수 있다.
-- 이유는 페이지 분할이라는 작업이 발생하기 때문이다. 페이지 분할 : 새로운 페이지를 준비해서 데이터를 나누는 작업

# 인덱스의 구조
-- 인덱스 구조를 통해 인덱스를 생성하면 왜 데이터가 정렬되는지, 어떤 인덱스가 더 효율적인지 살펴보자
## 클러스터형 인덱스 구성하기
-- 이번에는 클러스터형 인덱스와 보조 인덱스의 구조의 차이를 살펴본다.
-- 우선 인덱스 없이 테이블을 생성해보자
use market_db;
create table cluster -- 클러스터형 인덱스를 테스트하기 위한 테이블
(mem_id	char(8),
mem_name varchar(10));
insert into cluster values('TWC','트와이스');
insert into cluster values('BLK','블랙핑크');
insert into cluster values('WMN','여자친구');
insert into cluster values('OMY','오마이걸');
insert into cluster values('GRL','소녀시대');
insert into cluster values('ITZ','잇지');
insert into cluster values('RED','레드벨벳');
insert into cluster values('APN','에이핑크');
insert into cluster values('SPC','우주소녀');
insert into cluster values('MMU','마마무');
-- 정렬된 순서를 확인해보자.(입력된 순서와 동일할 것이다)
SELECT * from cluster;
-- 이제 테이블의 mem_id에 클러스터형 인덱스를 구성해보자
-- 앞서 배웠듯이 mem_id를 Primary Key로 지정하면 클러스터형 인덱스로 구성된다.
alter table cluster
	add constraint
    primary key(mem_id);
-- 데이터의 정렬을 다시 확인해보자(mem_id를 기준으로 오름차순 정렬되어 있다)
SELECT * from cluster;
## 보조인덱스 구성하기
-- 이번에는 동일한 데이터로 보조 인덱스를 만들어보자
use market_db;
create table second
(mem_id char(8),
mem_name varchar(10));
insert into second values('TWC','트와이스');
insert into second values('BLK','블랙핑크');
insert into second values('WMN','여자친구');
insert into second values('OMY','오마이걸');
insert into second values('GRL','소녀시대');
insert into second values('ITZ','잇지');
insert into second values('RED','레드벨벳');
insert into second values('APN','에이핑크');
insert into second values('SPC','우주소녀');
insert into second values('MMU','마마무');
-- 고유키 제약조건으로 보조 인덱스를 생성해보자
alter table second
	add constraint
    unique (mem_id);
select * from second;

## 클러스터형 인덱스와 보조 인덱스의 작동방식은 책에 그림을 통해 보는 것이 효율적이다.
## 297 p.







