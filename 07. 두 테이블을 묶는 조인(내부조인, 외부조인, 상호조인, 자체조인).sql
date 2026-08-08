# 두 테이블을 묶는 조인
-- 두 개의 테이블이 서로 관계되어 있는 상태를 고려해서 학습해보자

# 조인이란?
-- 두 개의 테이블을 서루 묶어서 하나의 결과를 만들어 내는 것.

# 내부 조인
-- 두 테이블의 조인을 위해서는 테이블이 일대다(one to many) 관계로 연결되어야 한다.
-- 일대다 관계란, 한쪽 테이블에는 하나의 값만 존재해야 하지만, 연결된 다른 테이블에는 여러 개의 값이 존재할 수 있는 관계를 말한다.
-- ex) market_db에서 회원테이블과 구매테이블의 관계
-- 		회원 테이블에서 아이디를 기본키(primary key, PK)로 지정했다. 구매 테이블에서는 아이디가 외래키(foreign key, FK)로 지정되어있다. 이는 회원은 1명이지만 구매는 여러번 할 수 있다라느 뜻이다.
-- 		그래서 일대다 관계는 주로 PK와 FK의 관계로 이루어져 있기에, PK - FK관계라고 부르기도 한다.
-- 일반적으로 조인이라고 부른 넋은 내부 조인을 말하는 것으로, 조인 중에서 가장 많이 사용된다.
/*
select <열 목록>
from <첫 번째 테이블>
	inner join <두 번째 테이블>
    on <조인될 조건>
[where 검색 조건]
*/
-- 구매 테이블에서 GRL이라는 아이디를 가진 사람이 구매한 사람이 구매한 물건을 발송하기 위해 조인으로 이름/주소/연락처 등을 검색할 수 있다.
use market_db;
select * 
from buy
inner join member
on buy.mem_id = member.mem_id
where buy.mem_id = 'GRL';
-- where buy.mem_id = 'GRL' 을 생략하면 모든 행이 회원 테이블과 결합된다.
select * 
from buy
inner join member
on buy.mem_id = member.mem_id;
-- 열이 너무 많으므로 이번에는 필요한 아이디/이름/구매 물품/주소/연락처만 추출해보자
select buy.mem_id '아이디', member.mem_name '멤버 이름' , buy.prod_name '구매 물품' , member.addr '주소' , concat(member.phone1, member.phone2) '연락처'
from buy
inner join member
on buy.mem_id = member.mem_id;
-- 위처럼 코딩을 하면 코드가 너무 길어져서 오히려 복잡해 보인다.
-- 이럴 때 별칭을 이용하면 좀 더 짧게 줄일 수 있다.
select b.mem_id '아이디', m.mem_name '멤버 이름' , b.prod_name '구매 물품' , m.addr '주소' , concat(m.phone1, m.phone2) '연락처'
from buy b
inner join member m
on b.mem_id = m.mem_id;
-- 결과를 보면 구매한 회원의 구매 기록만 있는데, 구매 하지 않은 회원의 이름/주소도 같이 검색되도록 하려면 어떻게 해야할까?, 양쪽 중에 한곳이라도 내용이 있을 때 조인하려면 외부 조인을 사용해야 한다.
-- "우리 사이트에서 한 번이라도 구매한 기록이 있는 회원들에게 감사의 안내문을 발송해보자"라고 했을 때 중복된 이름은 필요없으므로 DISTINCT문을 사용할 수 있다.
select distinct m.mem_id, m.mem_name, m.addr
from buy b
inner join member m
on b.mem_id = m.mem_id
order by m.mem_id;

# 외부조인
-- 한쪽에만 데이터가 있어도 결과가 나온다.
/*
select <열 목록>
<left | right | full? outer join <두 번째 테이블(right 테이블)>
on <조인될 조건>
[where 검색 조건];
*/
-- 전체 회원 구매 기록(구매 기록이 없느 회원의 정보도 함께) 출력해보자
select m.mem_id, m.mem_name, b.prod_name, m.addr
from member m
left outer join buy b -- 왼쪽에 있는 회원 테이블(member)을 기준으로 외부조인하자 / 뜻은 왼쪽 테이블의 내용은 모두 출력되어야 한다 정도로 해석하면 기억하기 쉽다.
on m.mem_id = b.mem_id
order by m.mem_id;
-- right outher join으로 동일한 결과를 출력하려면 단순히 왼쪽과 오른쪽 테이블의 위치만 바꿔주면 된다.
select m.mem_id, m.mem_name, b.prod_name, m.addr
from buy b
right outer join member m
on m.mem_id = b.mem_id
order by m.mem_id;
-- 회원으로 가입만 하고, 한 번도 구입한 적 없는 회원의 목록을 추출해봦
select m.mem_id, m.mem_name, b.prod_name, m.addr
from member m
left outer join buy b
on m.mem_id = b.mem_id
where b.prod_name is null
order by m.mem_id;
-- full outer join은 왼쪽이든 오른쪽이든 한쪽에 들어 있는 내용이면 출력한다.

# 기타조인
# 상호조인 : 한쪽 테이블의 모든 행과 다른 쪽 테이블의 모든 행을 조인시키는 기능
-- ex) 회원 테이블의 첫 행이 구매 테이블의 12개의 행과 결합, 두번째 행도 12개의 행과 결합 ... 즉, 회원테이블의 10개행과 구매 테이블의 12개 행을 곱해서 120개의 결과가 생성된다.
select * from buy cross join member;
-- on 구문을 사용할 수 없다.
-- 결과의 내용은 의미가 없다. 랜덤으롲 조인하기 때문이다.
# 자체 조인 : 자신이 자신과 조인한다. / 실무에선 자체 조인을 많이 사용하진 않지만, 대표적인 사례로 회사의 조직 관계를 살펴볼 수 있다.
-- 먼저 조직도를 테이블로 표현해보자
use market_db;
create table emp_table(emp char(4), manager char(4), phone varchar(8));
insert into emp_table values('대표', null, '0000');
insert into emp_table values('영업이사', '대표', '1111');
insert into emp_table values('관리이사', '대표', '2222');
insert into emp_table values('정보이사', '대표', '3333');
insert into emp_table values('영업과장', '영업이사', '1111-1');
insert into emp_table values('경리부장', '관리이사', '2222-1');
insert into emp_table values('인사부장', '관리이사', '2222-2');
insert into emp_table values('개발팀장', '정보이사', '3333-1');
insert into emp_table values('개발주임', '정보이사', '3333-1-1');
-- 자체조인 형식
/*
select <열 목록>
from <테이블> 별칭a
inner join <테이블> 별칭b
on <조인될 조건>
[where 검색 조건]
*/
-- emp_table을 emp_table A, emp_table B로 별칭을 지정해 각각 별개의 테이블 처럼 사용해서, 경리부장 직속 상관의 연락처를 알아보자
select A.emp "직원", B.emp "직속상관", B.phone "직속상관연락처"
from emp_table A
inner join emp_table B
on A.manager = B.emp
where A.emp = '경리부장';



















