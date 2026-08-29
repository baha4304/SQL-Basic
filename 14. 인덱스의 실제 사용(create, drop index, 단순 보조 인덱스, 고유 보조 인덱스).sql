# 인덱스의 실제 사용
-- 생성 : CREATE index
/*
CREATE [UNIQUE] INDEX 인덱스_이름
	on 테이블_이름(열_이름) [ASC|DESC]
*/
-- 제거 : DROP index
/*
DROP index 인덱스_이름 on 테이블_이름
*/

# 인덱스 생성 및 제거 문법
-- 테이블을 생성할 때 특정 열을 기본 키, 고유키로 설정하면 인덱스가 자동 생성된다.
-- Primary Key는 클러스터형을, Unique는 보조 인덱스가 생성된다.
-- 그 외 직접 인덱스를 생성하려면 Create Index 문을 사용해야 한다.
-- Create index문으로 생성한 인덱스는 Drop index로 제거할 수 있다. 주의 할 점은 기본키, 고유키로 자동 생성된 인덱스는 drop index로 제거하지 못한다.

# 인덱스 생성 및 제거 실습
## 인덱스 생성 실습
use market_db;
select * from member;
show index from member; -- key_name이 Primary 이므로 클러스터형 인덱스를 의미한다. 현재 member에는 mem_id에 클러스터형 인덱스가 1개만 설정되어 있다.
-- 이번에는 인덱스의 크기를 확인해보자
show table status like 'member';
-- data_length는 클러스터형 인덱스의 크기를 byte단위로 표시한 것이다.
-- index_length는 보조 인덱스의 크기를 나타내는데, member에는 보조 인덱스가 없기에 표시되지 않는다.
-- 이미 클러스터형 인덱스가 있으므로 member테이블에는 더 이상 클러스터형 인덱스를 생성할 수 없다.
-- 주소에 중복을 허용하는 단순 보조 인덱스를 생성하자.
create index idx_member_addr
	on member(addr);
-- 새로 생성된 인덱스를 확인해보자
show index from member;
-- 주의할 점은 non_unqiue가 1로 설정 되어 있으므로 고유 보조 인덱스가 아니라는 것이다. 즉 중복된 데이터를 허용한다.
-- 이번엔 보조 인덱스가 추가되었으므로 전체 인덱스의 크기를 다시 확인해보자
show table status like 'member';
-- index_length 부분이 보조 인덱스의 크기인데, 이상하게도 0으로 나온다.
-- 바로 앞에서 보조 인덱스 idx_member_addr이 생성된 것을 확인했는데, 생성한 인덱스를 실제로 적용시키려면 analyze table문으로 먼저 테이블을 분석/처리해줘야 한다.
analyze table member;
show table status like 'member';
-- 이제 보조 인덱스의 크기가 잘 보인다(생성된 것이 확인된다)
-- 이번에는 인원수(mem_number)에 중복을 허용하지 않는 고유 보조 인덱스를 생성해본다.
create unique index idx_member_mem_number
	on member(mem_number);
-- 인원수가 4인 그룹이 여럿 있기에 인원수 열에는 보조 인덱스를 생성할 수 없다 나온다.
-- 이번에는 회원 이름에 고유 보조 인덱스를 생성해보자
create unique index idx_member_mem_name
	on member(mem_name);
-- 잘 만들어 졌는지 확인해보자
show index from member;    
-- 이제는 중복이 허용 안되는, id, name이 겹치지 않게 회원가입을 해야한다.

# 인덱스의 활용 실습
-- 지금까지 만든 인덱스가 어느 열에 있는지 확인해보자
analyze table member; -- 지금까지 만든 인덱스를 모두 적용
show index from member; -- column_name을 보며 어느 열에 인덱스가 생성되어 있는지 확인 가능
-- 이번에는 전체를 조회해보자
select * from member;
-- 결과 중 execution plan 창을 확인하면 인덱스 사용 여부를 파악할 수 있다. 
-- full table scan이기에, 인덱스를 사용하지 않고, 첫 페이지부터 끝 페이지까지 넘겨본 것이다.
-- 이번에는 인덱스가 생성된 mem_name값이 에이핑크인 행을 조회해보자
select mem_id, mem_name, addr  from member
	where mem_name = '에이핑크';
-- execition plan을 보면 sigle row라고 되어 있는데, 이는 인덱스를 사용해서 결과를 얻었다는 의미이다.
-- 이번에는 숫자의 범위로 조회해보자.
-- 먼저 숫자로 구성된 인원수(mem_number)로 단순 보조 인덱스를 만들자.
create index id_member_mem_number on member(mem_number);
analyze table member;    
-- 인원수가 7명 이상인 그룹의 이름과 인원수를 조회해보자
select mem_name, mem_number from member where mem_number >= 7;
-- execition plan을 보면 index range scan 라고 되어 있는데, mem_number >= 7 처럼 숫자의 범위로 조회하는 것도 인덱스를 사용한다.

# 인덱스를 사용하지 않을 때
-- 인덱스가 존재하고 where절에 열 이름이 나와도 인덱스를 사용하지 않는 경우가 있다.
-- 인원 수가 1명 이상인 회원을 조회해보자
select mem_name, mem_number
	from member
	where mem_number >=1;
-- execution을 살펴보면 전체로 검색했다 나온다.
-- 조건에 해당하는 결과가가 대부분의 행을 가져와야 하므로, 인덱스를 왔다갔다 하는 것보다 테이블을 차례대로 읽는 것이 효율적이다. 
-- 또 다른 경우도 살펴보자
select mem_name, mem_number from member
	where mem_number*2 >= 14;
-- where조건에 연산이 가해지면 인덱스를 사용하지 않는다.
-- 이런 경우에는 다음과 같이 수정하면 된다.
select mem_name, mem_number from member
	where mem_number >= 14/2;
    
# 인덱스 제거 실습
-- 먼저 인덱스의 이름을 확인하자.
show index from member;
-- 클러스터형 인덱스와 보조인덱스가 섞여 있을 때는 보조 인덱스를 먼저 제거하는 것이 좋다.
-- 보조 인덱스는 어떤 것을 먼저 제거해도 상관없다.
drop index idx_member_mem_name on member;
drop index idx_member_addr on member;
drop index id_member_mem_number on member;
-- 마지막으로 기본 키 지정으로 자동 생성된 클러스터형 인덱스를 제거 하면 된다.
alter table member drop primary key;
-- 오류가 발생하는데 이는, member의 mem_id열을 buy가 참조하고 있기 때문이다.
-- 그러므로 기본키를 제거하기 전에 외래 키 관계를 제거하면 된다.
-- 테이블에는 여러 개의 외래키가 있을 수 있다. 그래서 먼저 외래 키의 이름을 알아내야 한다.
-- information_schema 데이터베이스의 referential_constraints테이블을 조회하면 외래키의 이름을 알 수 있다.
select table_name, constraint_name from information_schema.referential_constraints where constraint_schema = 'market_db';
-- 이제 외래 키 이름을 알았으니 외래키를 먼저 제거하고 기본 키를 제거하면 된다.
alter table buy drop foreign key buy_ibfk_1;
alter table member drop primary key;
-- 이제 모든 인덱스가 제거되었다.
show index from member;