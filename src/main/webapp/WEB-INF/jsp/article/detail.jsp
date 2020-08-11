<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<c:set var="pageName" value="게시물 상세" />
<%@ include file="../part/head.jspf"%>

<style>
body {
	text-align: center;
}

.body {
	border: 3px black double;
	height: 500px;
	margin-left: 18%;
	margin-right: 18%;
}

.reply-list-box {
	text-align: -webkit-center;
	border: 3px black double;
	border-top: none;
	margin-left: 20%;
	margin-right: 20%;
}

.reply-body {
	text-align: center;
}

.reply-list-box>table>tbody>tr[data-modify-mode="N"] .modify-mode-visible
	{
	display: none;
}

.reply-list-box>table>tbody>tr[data-modify-mode="Y"] .modify-mode-invisible
	{
	display: none;
}

.reply-list-box>table>tbody>tr>.reply-body-td>.modify-mode-visible>form
	{
	width: 100%;
	display: block;
}

.reply-list-box>table>tbody>tr>.reply-body-td>.modify-mode-visible>form>textarea
	{
	width: 100%;
	height: 100px;
	box-sizing: border-box;
	display: block;
}

.reply-write>form {
	display: block;
	width: 100%;
}

.reply-write>form>table {
	width: 100%;
	border-collapse: collapse;
}

.reply-write>form>table th, .reply-write>form>table td {
	border: 1px solid black;
	padding: 10px;
}

.reply-write>form>table textarea {
	width: 100%;
	display: block;
	box-sizing: border-box;
	height: 100px;
}

.direction {
	display: flex;
	justify-content: space-between;
}

.table-box {
	margin-left: 18%;
	margin-right: 18%;
	margin-bottom: 10px;
}

.table-box>table>tbody>tr>td>button {
	margin-left: 10px;
	margin-right: 10px;
}
.form-control-box
>
{
}
</style>
<h1>게시물 상세</h1>

<div>
	번호 : ${article.id} <br> 날짜 : ${article.regDate} <br> 제목 :
	${article.title} <br> 조회수 : ${article.hit}<br>
</div>
<div class="body" style="margin-top: 20px;">내용 : ${article.body}</div>

<!-- 댓글작성 -->
<c:if test="${isLogined}">
	<h2 class="con">댓글 작성</h2>

	<script>
		function ArticleWriteReplyForm__submit(form) {
			form.body.value = form.body.value.trim();
			if (form.body.value.length == 0) {
				alert('댓글을 입력해주세요.');
				form.body.focus();
				return;
			}

			var startUploadFiles = function(onSuccess) {
				var fileUploadFormData = new FormData(form);
				fileUploadFormData.delete("relTypeCode");
				fileUploadFormData.delete("relId");
				fileUploadFormData.delete("body");
				
				$.ajax({
					url : './../file/doUploadAjax',
					data : fileUploadFormData,
					processData : false,
					contentType : false,
					dataType:"json",
					type : 'POST',
					success : onSuccess
				});
			}
			var startWriteReply = function(fileIdsStr, onSuccess) {
				$.ajax({
					url : './../reply/doWriteReplyAjax',
					data : {
						fileIdsStr: fileIdsStr,
						body: form.body.value,
						relTypeCode: form.relTypeCode.value,
						relId: form.relId.value
					},
					dataType:"json",
					type : 'POST',
					success : onSuccess
				});
			};
			startUploadFiles(function(data) {
				var idsStr = data.body.fileIdsStr;
				if (data && data.body && data.body.fileIdsStr) {
					idsStr = data.body.fileIdsStr;
				}
				startWriteReply(idsStr, function(data) {
					if (data.msg) {
						alert(data.msg)	
					}
					form.body.value = '';
					form.file__reply__0__common_attachment__1.value = '';
				});
			});
		}
	</script>

	<form class="table-box con form1"
		onsubmit="ArticleWriteReplyForm__submit(this); return false;">
		<input type="hidden" name="relTypeCode" value="article" /> <input
			type="hidden" name="relId" value="${article.id}" />
		<table>
			<tbody>
				<tr>
					<th style="width: 84px; text-align: center;">내용</th>
					<td>
						<div class="form-control-box">
							<textarea maxlength="300" name="body" placeholder="내용을 입력해주세요."
								style="width: 100%; height: 50px;"></textarea>
						</div>
					<th>첨부1 비디오</th>
					<td>
						<div class="form-control-box">
							<input type="file" accept="video/*" capture
								name="file__reply__0__common__attachment__1">
						</div>
					</td>
					<td><input type="submit" value="작성"></td>
				</tr>
			</tbody>
		</table>
	</form>
</c:if>


<!--  댓글 리스트  -->
<div class="reply-list-box table-box con">
	<table>
		<colgroup>
			<col width="80">
			<col width="180">
			<col width="180">
			<col>
			<col width="200">
		</colgroup>
		<thead>
			<tr>
				<th>번호</th>
				<th>날짜</th>
				<th>작성자</th>
				<th>내용</th>
				<th>비고</th>
			</tr>
		</thead>
		<tbody>

		</tbody>
	</table>
</div>

<style>
.reply-modify-form-modal {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: rgba(0, 0, 0, 0.4);
	display: none;
}

.reply-modify-form-modal-actived .reply-modify-form-modal {
	display: flex;
}
</style>

<div class="reply-modify-form-modal flex flex-ai-c flex-jc-c">
	<form action="" class="form1 bg-white padding-10"
		onsubmit="ReplyList__submitModifyForm(this); return false;">
		<input type="hidden" name="id" />
		<div class="form-row">
			<div class="form-control-label">내용</div>
			<div class="form-control-box">
				<textarea name="body" placeholder="내용을 입력해주세요."></textarea>
			</div>
		</div>
		<div class="form-row">
			<div class="form-control-label">수정</div>
			<div class="form-control-box">
				<button type="submit">수정</button>
				<button type="button" onclick="ReplyList__hideModifyFormModal();">취소</button>
			</div>
		</div>
	</form>
</div>

<script>
	var ReplyList__$box = $('.reply-list-box');
	var ReplyList__$tbody = ReplyList__$box.find('tbody');
	var ReplyList__lastLodedId = 0;
	var ReplyList__submitModifyFormDone = false;
	function ReplyList__submitModifyForm(form) {
		if (ReplyList__submitModifyFormDone) {
			alert('처리중입니다.');
			return;
		}
		form.body.value = form.body.value.trim();
		if (form.body.value.length == 0) {
			alert('내용을 입력해주세요.');
			form.body.focus();
			return;
		}
		var id = form.id.value;
		var body = form.body.value;
		ReplyList__submitModifyFormDone = true;
		$.post('../reply/doModifyReplyAjax', {
			id : id,
			body : body
		}, function(data) {
			if (data.resultCode && data.resultCode.substr(0, 2) == 'S-') {
				// 성공시에는 기존에 그려진 내용을 수정해야 한다.!!
				var $tr = $('.reply-list-box tbody > tr[data-id="' + id
						+ '"] .reply-body');
				$tr.empty().append(body);
			}
			ReplyList__hideModifyFormModal();
			ReplyList__submitModifyFormDone = false;
		}, 'json');
	}
	function ReplyList__showModifyFormModal(el) {
		$('html').addClass('reply-modify-form-modal-actived');
		var $tr = $(el).closest('tr');
		var originBody = $tr.data('data-originBody');
		var id = $tr.attr('data-id');
		var form = $('.reply-modify-form-modal form').get(0);
		form.id.value = id;
		form.body.value = originBody;
	}
	function ReplyList__hideModifyFormModal() {
		$('html').removeClass('reply-modify-form-modal-actived');
	}
	function ReplyList__loadMoreCallback(data) {
		if (data.body.replies && data.body.replies.length > 0) {
			ReplyList__lastLodedId = data.body.replies[data.body.replies.length - 1].id;
			ReplyList__drawReplies(data.body.replies);
		}
		setTimeout(ReplyList__loadMore, 2000);
	}
	function ReplyList__loadMore() {
		$.get('../reply/getForPrintReplies', {
			articleId : param.id,
			from : ReplyList__lastLodedId + 1
		}, ReplyList__loadMoreCallback, 'json');
	}
	function ReplyList__drawReplies(replies) {
		for (var i = 0; i < replies.length; i++) {
			var reply = replies[i];
			ReplyList__drawReply(reply);
		}
	}
	function ReplyList__delete(el) {
		if (confirm('삭제 하시겠습니까?') == false) {
			return;
		}
		var $tr = $(el).closest('tr');
		var id = $tr.attr('data-id');
		$.post('./../reply/doDeleteReplyAjax', {
			id : id
		}, function(data) {
			$tr.remove();
		}, 'json');
	}
	function ReplyList__drawReply(reply) {
		var html = '';
		html += '<tr data-id="' + reply.id + '">';
		html += '<td>' + reply.id + '</td>';
		html += '<td>' + reply.regDate + '</td>';
		html += '<td>' + reply.extra.writer + '</td>';
		html += '<td>';
		html += '<div class="reply-body">' + reply.body + '</div>';
		if (reply.extra.file__common__attachment__1) {
            var file = reply.extra.file__common__attachment__1;
            html += '<video controls src="
                /usr/file/streamVideo?id=' + file.id + '">video not supported</video>';
        }
		
		html += '</td>';
		html += '<td>';

		if (reply.extra.actorCanDelete) {
			html += '<button type="button" onclick="ReplyList__delete(this);">삭제</button>';
		}
		
		if (reply.extra.actorCanModify) {
			html += '<button type="button" onclick="ReplyList__showModifyFormModal(this);">수정</button>';
		}
		
		html += '</td>';
		html += '</tr>';
		
		var $tr = $(html);
		$tr.data('data-originBody', reply.body);
		ReplyList__$tbody.prepend($tr);
	}
	ReplyList__loadMore();
</script>


<div class="direction" style="margin-right: 20px; margin-left: 20px;">
	<c:if test="${article.delStatus == 'false' && article.id > 0}">
		<a href="./detail?id=${article.id-1}">BEFORE</a>
		<a href="./detail?id=${article.id+1}">NEXT</a>
	</c:if>
</div>
<div class="btns" style="margin-bottom: 20px;">
	<a href="./modify?id=${article.id}">modify</a> <a
		href="./delete?id=${article.id}">delete</a>
</div>

<%@ include file="../part/foot.jspf"%>