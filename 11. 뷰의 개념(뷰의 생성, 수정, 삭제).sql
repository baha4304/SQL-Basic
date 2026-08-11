# 가상의 테이블 뷰
-- 뷰(view)는 데이터베이스 개체 중에 하나이다.
-- 테이블처럼 데이터를 가지고 있지는 않다. 비유하자면 바로가기아이콘 같은 느낌이다.
-- 단순뷰 : 하나의 테이블과 연관된 뷰
-- 복합뷰 : 2개 이상의 테이블과 연관된 뷰

# 뷰의 기본 생성
## 뷰의 기본 생성
-- 간단히 회원 테이블을 조회해보자
select mem_id, mem_name, addr from member;
-- 출력된 결과가 테이블인데, 이 실행결과를 v_member로 저장해놓고 실행하면 그것이 뷰이다.
/* 
-- 뷰 만들기
create view 뷰_이름
as
	select 문;
    
-- 뷰에 접근하기
select 열_이름 from 뷰_이름 where 조건
*/
-- 회원 테이블의 아이디, 이름, 주소에 접근하는 뷰 생성해보자
use market_db;
create view v_member
as select mem_id, mem_name, addr from member;
-- 뷰를 불러내보자
select * from v_member;
-- 필요한 열만 보거나 조건식을 넣을 수도 있다.
select mem_name, addr from v_member where addr in ('경기','서울') order by addr;
## 뷰를 사용하는 이유
-- 보안에 도움이 된다. / 중요한 개인정보는 숨겨서 테이블로 만들 수 있음.
-- 복잡한 SQL을 단순하게 만들 수 있다. / 
select b.mem_id, m.mem_name, b.prod_name, m.addr, concat(m.phone1,m.phone2) '연락처'
from buy b inner join member m on b.mem_id = m.mem_id;
-- 이런 SQL을 자주 사용한다면 그때마다 코드로 불러오기보단, 뷰로 저장해두고 불러오는게 더 빠를 것이다.
create view v_memberbuy as
select b.mem_id, m.mem_name, b.prod_name, m.addr, concat(m.phone1,m.phone2) '연락처'
from buy b inner join member m on b.mem_id = m.mem_id;
-- 이제 위의 SQL문의 결과를 테이블이라 생각하고 뷰로 불러오면 된다.
select * from v_memberbuy where mem_name = '블랙핑크';

# 뷰의 실제 작동
## 뷰의 실제 생성, 수정, 삭제
-- 뷰를 생성하면서, 사용될 열 이름을 테이블과 다르게 지정할 수 있다.
-- 별칭은 열 이름 뒤에 작은 혹은 큰 따옴표로 묶어주고, 형식상 as를 붙여준다(as를 붙이면 코드가 명확해 보이는 장점이 있다).
-- 뷰를 조회할 때 열 이름에 공백이 있으면 백틱(`)으로 묶어줘야 한다(백틱(`)은 키보드 1 왼쪽에 있는 키이다).
use market_db;
create view v_viewtest1 as
select b.mem_id 'member ID', m.mem_name as 'member name', b.prod_name as 'product name', concat(m.phone1,m.phone2) as 'office phone'
from buy b inner join member m on b.mem_id = m.mem_id;
-- 실행해보자
select distinct `member ID`, `member name` from v_viewtest1;
-- 뷰의 수정은 alter view 구문을 사용하며, 열 이름에 한글을 사용해도 된다.
alter view v_viewtest1 as
select b.mem_id '회원 아이디', m.mem_name as '회원 이름', b.prod_name as '제품 이름', concat(m.phone1,m.phone2) as '연락처'
from buy b inner join member m on b.mem_id = m.mem_id;
-- 출력해보자
select distinct `회원 아이디`, `회원 이름` from v_viewtest1;
-- 뷰의 삭제는 drop view를 사용한다.
drop view v_viewtest1;
-- 기존에 생성된 뷰에 대한 정보를 확인할 수 있다.
-- 우선 간단한 뷰를 다시 생성해보자
use market_db;
create or replace view v_viewtest2 as
select mem_id, mem_name, addr from member;
-- describe 문으로 기존 뷰의 정보를 확인할 수 있다.
describe v_viewtest2;
-- primary key 등의 정보는 확인되지 않는다.
describe member;
-- show create view문으로 뷰의 소스 코드도 확인할 수 있다.
show create view v_viewtest2;
## 뷰를 통한 데이터의 수정/삭제
-- v_member 뷰를 통해 데이터를 수정해보자
update v_member set addr = '부산' where mem_id = 'BLK';
-- 이번에는 데이터를 입력해보자
insert into v_member(mem_id, mem_name, addr) values('BTS','방탄소년단','경기');
-- v_member가 참조하는 member테이블의 열 중에서 mem_number 열은 not null로 설정되었기 때문에 반드시 입력해줘야 하기에 오류가 난다.
-- 만약 데이터를 입력하고 싶다면 뷰를 재정의 해서, 수정해야한다.
-- 이번에는 지정한 범위로 뷰를 생성해보자
create view v_height167 as
select * from member where height >= 167;
select * from v_height167
## 뷰를 통한 데이터의 입력
-- v_height167 뷰에서 키가 167미만인 데이터를 입력해보자
insert into v_height167 values('TRA','티아라',6,'서울',null,null,159,'2005-01-01');
-- v_height167 뷰는 167이상만 보이도록 만든 뷰인데, 167미만인 데이터가 들어갔다. 일단 뷰를 확인해보자
select * from v_height167;
-- 방금전에 입력한 티아라는 보이지 않는다.
-- 이제 아예 167미만인 데이터는 입력되지 않도록 옵션을 설정하자 / with check option
alter view v_height167
as select * from member where height >= 167 with check option;
insert into v_height167 values('TOB','텔레토비',4,'영국',null,null,140,'1995-01-01');
-- 이제 167미만의 데이터는 입력되지 않는다.
## 뷰가 참조하는 테이블의 삭제
-- 뷰가 참조하는 테이블을 삭제해보자
drop table if exists buy,member;
-- 이제 뷰를 호출해보자
select * from v_height167;
-- 테이블이 없으므로 뷰가 삭제되었다.
-- 뷰가 조회되지 않으면 check table문으로 뷰의 상태를 확인해볼 수 있다.
check table v_height167;













