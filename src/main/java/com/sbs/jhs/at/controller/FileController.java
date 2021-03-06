package com.sbs.jhs.at.controller;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartRequest;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import com.google.common.base.Joiner;
import com.sbs.jhs.at.dto.File;
import com.sbs.jhs.at.dto.ResultData;
import com.sbs.jhs.at.service.FileService;
import com.sbs.jhs.at.service.VideoStreamService;
import com.sbs.jhs.at.util.Util;

import reactor.core.publisher.Mono;

@Controller
public class FileController {
	@Autowired
	private FileService fileService;
	@Autowired
	private VideoStreamService videoStreamService;

	@RequestMapping("/usr/file/streamVideo")
	public Mono<ResponseEntity<byte[]>> streamVideo(
			@RequestHeader(value = "Range", required = false) String httpRangeList, int id) {
		File file = fileService.getFileById(id);
		final ByteArrayInputStream is = new ByteArrayInputStream(file.getBody());

		return Mono.just(videoStreamService.prepareContent(is, file.getFileSize(), file.getFileExt(), httpRangeList));
	}
	
	@RequestMapping("/usr/file/doUploadAjax")
	@ResponseBody
	public ResultData uploadAjax(@RequestParam Map<String, Object> param, HttpServletRequest req,
			MultipartRequest multipartRequest) {

		Map<String, MultipartFile> fileMap = multipartRequest.getFileMap();

		List<Integer> fileIds = new ArrayList<>();

		for (String fileInputName : fileMap.keySet()) {
			MultipartFile multipartFile = fileMap.get(fileInputName);

			String[] fileInputNameBits = fileInputName.split("__");

			if (fileInputNameBits[0].equals("file")) {
				String relTypeCode = fileInputNameBits[1];
				int relId = Integer.parseInt(fileInputNameBits[2]);
				String typeCode = fileInputNameBits[3];
				String type2Code = fileInputNameBits[4];
				int fileNo = Integer.parseInt(fileInputNameBits[5]);
				String originFileName = multipartFile.getOriginalFilename();
				String fileExtTypeCode = Util.getFileExtTypeCodeFromFileName(multipartFile.getOriginalFilename());
				String fileExtType2Code = Util.getFileExtType2CodeFromFileName(multipartFile.getOriginalFilename());
				String fileExt = Util.getFileExtFromFileName(multipartFile.getOriginalFilename()).toLowerCase();
				byte[] fileBytes = Util.getFileBytesFromMultipartFile(multipartFile);
				int fileSize = (int) multipartFile.getSize();

				int fileId = fileService.saveFile(relTypeCode, relId, typeCode, type2Code, fileNo, originFileName,
						fileExtTypeCode, fileExtType2Code, fileExt, fileBytes, fileSize);

				fileIds.add(fileId);
			}
		}

		Map<String, Object> rsDataBody = new HashMap<>();
		rsDataBody.put("fileIdsStr", Joiner.on("").join(fileIds));
		rsDataBody.put("fileIds", fileIds);

		return new ResultData("S-1", String.format("%d개의 파일을 저장했습니다.", fileIds.size()), rsDataBody);
	}
}