# market_db를 삭제(책을 학습하다 market_db를 다시 실행할 일이 생기면 필요한 내용)
DROP DATABASE IF EXISTS market_db;
# market_db를 다시 실행하기
create database market_db;

# select 문에서는 결과의 정렬을 위한 oreder by, 결과의 개수를 제한하는 limit, 중복된 데이터를 제거하는 distinct 등을 사용할 수 있다.
# 그리고 group by 절은 지정한 열의 데이터들을 같은 데이터끼리는 묶어서 결과를 추출한다.
# having절은 where절과 비슷해보이지만, group by 절과 함께 사용되는 것이 차이점이다.

# order by 절
/*
select 열_이름
	from 테이블_이름
    where 조건식
    group by 열_이름
    having 조건식
    order by 열_이름
    limit 숫자
*/

# order by 절은 결과의 값이나 개수에 대해서는 영향을 미치지는 않지만, 결과가 출력되는 순서를 조절한다.
-- 데뷔일자가 빠른 순서대로 출력해보자
select mem_id, mem_name, debut_date from member order by debut_date;
-- 데뷔일자가 늦은 순서대로 정렬해보자
select mem_id, mem_name, debut_date from member order by debut_date desc; -- descending의 약자
-- order by와 where절은 같이 사용할 수 있다.
-- 평균키가 164이상인 회원들을 키가 큰 순서대로 조회해보자
select mem_id, mem_name, debut_date, height from member where height >= 164 order by height desc; -- where절이 항상 order by절보다 앞에 나와야한다.
-- 정렬기준은 1개 열이 아니라 여러 개 열로 지정할 수 있다.
-- 우선 첫번째 지정 열로 정렬한 후에 동일할 경우에는 다음 지정 열로 정렬할 수 있다.
select mem_id, mem_name, debut_date, height from member where height >= 164 order by height desc, debut_date asc; -- 키순으로 나열하되, 평균키가 같으면 데뷔일자가 빠른순으로 정렬

# limit는 출력되는 개수를 제한한다.
select * from member limit 3;
-- 데뷔일자가 빠른 회원 3건만 추출해보자
select mem_name, debut_date from member order by debut_date limit 3;
-- limit 형식은 limit 시작,개수 이다. limit 0,3 : 0번째부터 3건
-- 필요하다면 중간부터 출력도 가능하다. ex) 평균키가 큰순으로 정렬하되, 3번째부터 2건만 조회
select mem_name, height from member order by height desc limit 3,2;

# distinct는 조회된 결과에서 중복된 데이터를 한 개만 남긴다.
select addr from member;
select distinct addr from member;

# group by 절은 말 그대로 그룹으로 묶어주는 역할을 한다. 
# 구매테이블에서 회원이 구매한 물품의 총 개수를 구할 수 있다.
-- 회원이 구매한 물품수량을 보자
select mem_id, amount from buy order by mem_id
-- group by와 함께 집계함수를 쓰면된다.
/*
sum()			: 합계
avg()			: 평균
min()			: 최소값
max()			: 최대값
count()			: 행의 개수 세기
count(distict)	: 행의 개수 세기(중복은 1개만 인정)
*/
-- 회원이 구매한 물품수량을 더해서 묶어주자
select mem_id, sum(amount) from buy group by mem_id
-- 별칭을 이용해 결과를 보기좋게 만들 수 있다.
select mem_id "회원 아이디", sum(amount) "총 구매 개수" from buy group by mem_id;
-- 이번에는 회원이 구매한 금액의 총합을 출력해보자
select mem_id "회원 아이디", sum(price*amount) "총 구매 금액" from buy group by mem_id;
-- 전체 회원의 물품 개수의 평균을 구해보자
select avg(amount) "평균 구매 개수" from buy;
-- 각 회원이 한 번 구매시 평군 몇 개를 구매했는지 알아보자
select mem_id, avg(amount) "평균 구매 개수" from buy group by mem_id;

# having절
-- sum()으로 회원별 총 구매 금액을 알아보자
select mem_id "회원 아이디", sum(price*amount) "총 구매 금액" from buy group by mem_id;
-- 결과 중에서 총 구매액이 1000이상인 회원에게만 사은품을 증정하려면 어떻게 해야할까?
-- 집계함수는 where절로 나타낼 수 없기에 having절을 사용한다.
select mem_id "회원 아이디", sum(price*amount) "총 구매 금액" from buy where sum(price*amount) > 1000 group by mem_id;
select mem_id "회원 아이디", sum(price*amount) "총 구매 금액" from buy group by mem_id having sum(price*amount) > 1000;
-- 만약 총 구매액이 큰 사용자부터 나타내려면 order by를 사용하면 된다.alter
select mem_id "회원 아이디", sum(price*amount) "총 구매 금액" from buy group by mem_id having sum(price*amount) > 1000 order by sum(price*amount) desc;












