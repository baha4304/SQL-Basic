# member 테이블의 member_name 열에 인덱스를 지정하라 / 인덱스 생성
create index idx_member_name on member(member_name);
# 아이유 값이 들어있는 행을 부르면, 인덱스를 이용해서 찾는 것을 볼 수 있다.
select *from member where member_name = '아이유'

# 뷰를 한마디로 정의하면 가상의 테이블이라 할 수 있다.
# 하지만 실제 데이터를 가지고 있지 않으며, 진짜 테이블에 링크된 개념이라고 생각하면 된다. / 뷰의 실체는 select문이다.

# 회원 테이블과 연결되는 회원 뷰르르 만들어보자
create view member_view
as
	select * from member;
    # 뷰로 호출했을 땐 내용을 수정하지 못한다 -> 보안이 좋다.
    select * from member_view;

# 스토이드 프로시저 : MySQL에서 제공하는 프로그래밍 기능, 여러 개의 SQL 문을 하나로 묶어서 편리하게 사용가능하다.
select * from member where member_name = '나훈아';
select * from product where product_name = '삼각김밥';
# 이렇게 항상 두 줄의 코드를 써야한다면 힘들것이다.
# 이 두개를 하나의 스토이드 프로시저로 만들어보자
delimiter //
create procedure myPROC()

begin
	select * from member where member_name = '나훈아';
	select * from product where product_name = '삼각김밥';
end //
delimiter ;
# 만들어진 스토어드 프로시저를 불러와보자
call myPROC();


SHOW CREATE DATABASE shop_db;
SHOW CREATE TABLE member;
SHOW CREATE TABLE product;
SHOW CREATE VIEW member_view;
SELECT * FROM member;
SELECT * FROM product;