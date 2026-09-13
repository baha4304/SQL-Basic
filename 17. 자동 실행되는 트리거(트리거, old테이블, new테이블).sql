# 자동 실행되는 트리거
-- 트리거의 사용을 통해서 데이터의 무결성을 올릴 수 있다.

# 트리거의 기본
-- 트리거는 테이블에 무슨 일이 일어나면 자동으로 실행된다.
## 트리거의 개요
-- 트리거란 테이블에 insert나 update 또는 delete 작업이 발생하면 자동으로 실행되는 코드이다.
## 트리거의 기본 작동
-- 트리거는 테이블에서 DML문(insert, update, delete 등)의 이벤트가 발생할 때 작동한다.
-- 트리거는 스토어드 프로시저와 문법이 비슷하지만 call문으로 직접 실행시킬 수는 없고 오직 테이블에 insert, update, delete 등의 이벤트가 발생할 경우에만 자동으로 실행된다.
-- 또한 스토어드 프로시저와 달리 in, out 매개변수를 사용할 수 없다. 
-- 테스트로 사용할 간단한 테이블을 만들어보자
use market_db;
DROP TABLE IF EXISTS trigger_table;
CREATE TABLE trigger_table(
    id INT PRIMARY KEY,
    txt VARCHAR(10)
);
insert into trigger_table values(1, '레드벨벳');
insert into trigger_table values(2, '잇지');
insert into trigger_table values(3, '블랙핑크');
-- 이제 테이블에 트리거를 부착해보자
drop trigger if exists myTrigger;
delimiter $$
create trigger myTrigger
	after delete -- delete 문이 발생된 이후에 작동하라는 의미
	on trigger_table
    for each row -- 각 행마다 적용시키라는 의미인데, 트리거에는 항상 써준다.
begin
	set @msg = '가수 그룹이 삭제됨'; -- 트리거 작동 시 작동되는 코드들
end $$
delimiter ;
-- 이제 트리거를 부착한 테이블에 값을 삽입하고 수정해보자
set @msg = '';
insert into trigger_table values(4, '마마무');
select @msg;
update trigger_table set txt = '블핑' where id = 3;
select @msg;
-- delete문을 사용하면 @msg에 트리거에서 설정한 내용이 들어갈 것이다.
delete from trigger_table where id = 4;
select @msg;

# 트리거 활용
-- 트리거는 테이블에 입력/수정/삭제되는 정보를 백업하는 용도로 활용할 수 있다.
-- market_db의 고객 테이블에 입력된 회원의 정보가 변경될 때 변경한 사용자, 시간, 변경 전의 데이터 등을 기록하는 트리거를 작성해보자
-- 실습이 복잡할 수 있으니 회원테이블의 열을 간단히 아이디, 이름, 인원, 주소 4개의 열로 구성된 가수 테이블로 복사하여 진행하자
use market_db;
create table singer (select mem_id, mem_name, mem_number, addr from member);
-- 가수 테이블에 insert나 update 작업이 일어나는 경우, 변경되기 전의 데이터를 저장할 백업 테이블을 미리 생성하자.
-- 백업 테이블에는 추가로 수정 또는 삭제인지 구분할 변경된 타입(modType), 변경된 날짜(modDate), 변강한 사용자(modUser)를 추가하자
create table backup_singer(
mem_id char(8) not null,
mem_name varchar(10) not null,
mem_number int not null,
addr char(2) not null,
modType char(2), -- 변경된 차입. 수정 또는 삭제
modDate date, -- 변경된 날짜
modUser varchar(30) -- 변경한 사용자
);
-- 이제 본격적으로 변경과 삭제가 발생할 때 작동하는 트리거를 singer테이블에 부착하자
drop trigger if exists singer_updateTrg;
delimiter $$
create trigger singer_updateTrg -- 트리거 이름
	after update -- update 후에 사용하도록 지정
	on singer
    for each row
-- old테이블은 update나 delete가 수행될 때, 변경되기 전의 데이터가 잠깐 저장되는 임시 테이블이다. 
begin
	insert into backup_singer values(old.mem_id, old.mem_name, old.mem_number, old.addr, '수정', curdate(), current_user());
end $$
delimiter ;
-- 이번에는 삭제가 발생했을 때 작동하는 트리거를 생성하자
drop trigger if exists singer_deleteTrg;
delimiter $$
create trigger singer_deleteTrg -- 트리거 이름
	after delete -- delete 후에 사용하도록 지정
	on singer
    for each row
-- old테이블은 update나 delete가 수행될 때, 변경되기 전의 데이터가 잠깐 저장되는 임시 테이블이다. 
begin
	insert into backup_singer values(old.mem_id, old.mem_name, old.mem_number, old.addr, '삭제', curdate(), current_user());
end $$
delimiter ;
-- 이제 데이터를 변경해보자
-- 한 건의 데이터를 업데이트하고, 여러 건을 삭제해보자
update singer set addr = '영국' where mem_id = 'BLK';
delete from singer where mem_number >= 7;
-- 방금 수정 또는 삭제된 내용이 잘 보관되어 있는지 결과를 확인해보자
-- 백업 테이블을 조회해보자
select * from backup_singer;
-- 이번에는 테이블의 모든 행 데이터를 삭제해보자
truncate table singer; -- 테이블의 모든 데이터를 한꺼번에 삭제하는 명령어
select * from backup_singer; -- 하지만 백업 테이블에는 들어가지 않았다. 왜냐하면 delete로 삭제하지 않았기 때문이다. 

# 트리거가 사용하는 임시테이블
-- 테이블에 insert, update, delete 작업이 수행되면 임시로 사용되는 시스템 테이블이 2개가 있다.
-- 이름은 new와 old이다.
-- 이 두 테이블은 MySQL이 알아서 생성하고 관리한다.
-- insert문이 실행되면 새 값은 테이블에 들어가기 전에 new 테이블에 잠깐 들어가 있다.
-- delete문이 실행되면 이전 값은 old테이블에 잠깐 저장된다.
-- update문이 실행되면 이전 값은 old테이블, 새 값은 new테이블에 들어가 있다.












