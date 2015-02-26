/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 50614
Source Host           : localhost:3306
Source Database       : schedule

Target Server Type    : MYSQL
Target Server Version : 50614
File Encoding         : 65001

Date: 2015-01-26 17:57:16
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `t_cluster`
-- ----------------------------
DROP TABLE IF EXISTS `t_cluster`;
CREATE TABLE `t_cluster` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL COMMENT '集群名称',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='服务器集群';

-- ----------------------------
-- Records of t_cluster
-- ----------------------------

-- ----------------------------
-- Table structure for `t_db_con`
-- ----------------------------
DROP TABLE IF EXISTS `t_db_con`;
CREATE TABLE `t_db_con` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `con_name` varchar(255) DEFAULT NULL COMMENT '数据库连接名',
  `db_name` varchar(64) NOT NULL COMMENT '数据库名',
  `type_id` tinyint(4) NOT NULL COMMENT '数据库类型ID',
  `con_type_id` tinyint(4) NOT NULL COMMENT '数据库连接类型ID',
  `username` varchar(64) DEFAULT NULL COMMENT '数据库连接用户名',
  `password` varchar(255) DEFAULT NULL COMMENT '数据库连接密码',
  `hostname` varchar(128) DEFAULT NULL COMMENT '主机名',
  `port` int(11) DEFAULT NULL COMMENT '数据库端口号',
  `charset` varchar(32) DEFAULT NULL COMMENT '数据库编码',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  `create_user` varchar(64) NOT NULL COMMENT '创建者',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据库连接信息';

-- ----------------------------
-- Records of t_db_con
-- ----------------------------

-- ----------------------------
-- Table structure for `t_db_con_type`
-- ----------------------------
DROP TABLE IF EXISTS `t_db_con_type`;
CREATE TABLE `t_db_con_type` (
  `id` tinyint(4) NOT NULL DEFAULT '0',
  `code` varchar(64) DEFAULT NULL COMMENT '代码',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据库连接类型';

-- ----------------------------
-- Records of t_db_con_type
-- ----------------------------
INSERT INTO `t_db_con_type` VALUES ('1', 'JDBC', 'Java Database Connectivity');
INSERT INTO `t_db_con_type` VALUES ('2', 'ODBC', 'Open Database Connectivity');
INSERT INTO `t_db_con_type` VALUES ('3', 'CLI', 'Command Line Interface');

-- ----------------------------
-- Table structure for `t_db_type`
-- ----------------------------
DROP TABLE IF EXISTS `t_db_type`;
CREATE TABLE `t_db_type` (
  `id` tinyint(4) NOT NULL DEFAULT '0',
  `code` varchar(64) NOT NULL COMMENT '代码',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据库类型';

-- ----------------------------
-- Records of t_db_type
-- ----------------------------
INSERT INTO `t_db_type` VALUES ('1', 'MYSQL', 'MySQL');
INSERT INTO `t_db_type` VALUES ('2', 'ORACLE', 'Oracle');
INSERT INTO `t_db_type` VALUES ('3', 'MSSQLSERVER', 'Microsoft SQL Server');
INSERT INTO `t_db_type` VALUES ('4', 'SYBASE', 'Sybase');
INSERT INTO `t_db_type` VALUES ('5', 'POSTGRESQL', 'PostgreSQL');
INSERT INTO `t_db_type` VALUES ('6', 'DB2', 'IBM DB2');
INSERT INTO `t_db_type` VALUES ('7', 'HIVE', 'Hadoop Hive');
INSERT INTO `t_db_type` VALUES ('8', 'DERBY', 'Apache Derby');
INSERT INTO `t_db_type` VALUES ('9', 'FS', 'Local File System');
INSERT INTO `t_db_type` VALUES ('10', 'HDFS', 'Hadoop Distributed File System');

-- ----------------------------
-- Table structure for `t_server`
-- ----------------------------
DROP TABLE IF EXISTS `t_server`;
CREATE TABLE `t_server` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cluster_id` int(11) DEFAULT NULL COMMENT '集群ID',
  `ip` varchar(64) NOT NULL COMMENT 'IP地址',
  `hostname` varchar(128) DEFAULT NULL COMMENT '主机名',
  `server_type` varchar(64) DEFAULT NULL COMMENT '服务器类型',
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='服务器';

-- ----------------------------
-- Records of t_server
-- ----------------------------

-- ----------------------------
-- Table structure for `t_task`
-- ----------------------------
DROP TABLE IF EXISTS `t_task`;
CREATE TABLE `t_task` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_name` varchar(255) DEFAULT NULL COMMENT '任务名称',
  `type_id` smallint(6) NOT NULL COMMENT '任务类型ID',
  `task_status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '任务状态（0:正常，1:暂停）',
  `description` varchar(255) DEFAULT NULL COMMENT '任务描述',
  `task_cycle` varchar(16) NOT NULL COMMENT '任务周期（day:天，week:周，month:月，hour:小时，interval:时间间隔）',
  `cycle_value` varchar(64) DEFAULT NULL COMMENT '周期值',
  `date_serial` tinyint(1) NOT NULL DEFAULT '0' COMMENT '时间串行（1表示串行）',
  `priority` tinyint(4) NOT NULL DEFAULT '0' COMMENT '任务优先级（值越小优先级越高）',
  `max_try_times` tinyint(4) NOT NULL DEFAULT '5' COMMENT '最多尝试次数',
  `start_time` datetime NOT NULL COMMENT '开始日期',
  `end_time` datetime DEFAULT NULL COMMENT '结束日期',
  `create_user` varchar(64) NOT NULL COMMENT '创建者',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_user` varchar(64) DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8 COMMENT='任务';

-- ----------------------------
-- Records of t_task
-- ----------------------------
INSERT INTO `t_task` VALUES ('1', '日报表1', '1', '1', '不串行，无依赖', 'day', null, '0', '0', '5', '2015-01-21 15:13:48', null, 'zhangchao', '2015-01-23 15:14:02', null, null);
INSERT INTO `t_task` VALUES ('2', '日报表2', '1', '1', '串行，无依赖', 'day', null, '1', '0', '5', '2015-01-21 15:14:44', null, 'zhangchao', '2015-01-23 15:14:52', null, null);
INSERT INTO `t_task` VALUES ('3', '日报表3', '1', '1', '不串行，依赖日任务', 'day', null, '0', '0', '5', '2015-01-21 15:15:40', null, 'zhangchao', '2015-01-23 15:15:50', null, null);
INSERT INTO `t_task` VALUES ('4', '日报表4', '1', '1', '不串行，依赖周任务', 'day', null, '0', '0', '5', '2015-01-21 15:17:29', null, 'zhangchao', '2015-01-23 15:17:37', null, null);
INSERT INTO `t_task` VALUES ('5', '日报表5', '1', '1', '不串行，依赖月任务', 'day', null, '0', '0', '5', '2015-01-23 15:18:14', null, 'zhangchao', '2015-01-23 15:18:28', null, null);
INSERT INTO `t_task` VALUES ('6', '日报表6', '1', '1', '不串行，依赖小时任务', 'day', null, '0', '0', '5', '2015-01-21 15:26:30', null, 'zhangchao', '2015-01-23 15:26:39', null, null);
INSERT INTO `t_task` VALUES ('7', '周报表1', '1', '1', '不串行，无依赖', 'week', '3', '0', '0', '5', '2015-01-01 15:20:17', null, 'zhangchao', '2015-01-23 15:20:37', null, null);
INSERT INTO `t_task` VALUES ('8', '周报表2', '1', '1', '串行，无依赖', 'week', '2', '1', '0', '5', '2015-01-05 15:21:16', null, 'zhangchao', '2015-01-23 15:21:28', null, null);
INSERT INTO `t_task` VALUES ('9', '周报表3', '1', '1', '不串行，依赖日任务', 'week', '3', '0', '0', '5', '2015-01-01 15:21:59', null, 'zhangchao', '2015-01-23 15:22:09', null, null);
INSERT INTO `t_task` VALUES ('10', '周报表4', '1', '1', '不串行，依赖周任务', 'week', '3', '0', '0', '5', '2015-01-02 15:22:55', null, 'zhangchao', '2015-01-23 15:23:05', null, null);
INSERT INTO `t_task` VALUES ('11', '周报表5', '1', '1', '不串行，依赖月任务', 'week', '2', '0', '0', '5', '2015-01-01 15:23:47', null, 'zhangchao', '2015-01-23 15:23:58', null, null);
INSERT INTO `t_task` VALUES ('12', '周报表6', '1', '1', '不串行，依赖小时任务', 'week', '3', '0', '0', '5', '2015-01-01 15:24:31', null, 'zhangchao', '2015-01-23 15:24:46', null, null);
INSERT INTO `t_task` VALUES ('13', '月报表1', '1', '1', '不串行，无依赖', 'month', '05', '0', '0', '5', '2014-11-01 15:29:07', null, 'zhangchao', '2015-01-23 15:29:17', null, null);
INSERT INTO `t_task` VALUES ('14', '月报表2', '1', '1', '串行，无依赖', 'month', '08', '1', '0', '5', '2014-11-07 15:29:44', null, 'zhangchao', '2015-01-23 15:29:58', null, null);
INSERT INTO `t_task` VALUES ('15', '月报表3', '1', '1', '不串行，依赖日任务', 'month', '07', '0', '0', '5', '2014-11-01 15:31:23', null, 'zhangchao', '2015-01-23 15:31:38', null, null);
INSERT INTO `t_task` VALUES ('16', '月报表4', '1', '1', '不串行，依赖周任务', 'month', '07', '0', '0', '5', '2014-12-01 15:32:10', null, 'zhangchao', '2015-01-23 15:32:26', null, null);
INSERT INTO `t_task` VALUES ('17', '月报表5', '1', '1', '不串行，依赖月任务', 'month', '10', '0', '0', '5', '2014-11-01 15:33:09', null, 'zhangchao', '2015-01-23 15:33:20', null, null);
INSERT INTO `t_task` VALUES ('18', '月报表6', '1', '1', '不串行，依赖小时任务', 'month', '10', '0', '0', '5', '2014-12-01 15:34:05', null, 'zhangchao', '2015-01-23 15:34:15', null, null);
INSERT INTO `t_task` VALUES ('19', '小时报表1', '1', '1', '不串行，无依赖', 'hour', null, '0', '0', '5', '2015-01-23 15:35:11', null, 'zhangchao', '2015-01-23 15:35:20', null, null);
INSERT INTO `t_task` VALUES ('20', '小时报表2', '1', '1', '串行，无依赖', 'hour', null, '1', '0', '5', '2015-01-23 15:35:58', null, 'zhangchao', '2015-01-23 15:36:09', null, null);
INSERT INTO `t_task` VALUES ('21', '小时报表3', '1', '1', '不串行，依赖日任务', 'hour', null, '0', '0', '5', '2015-01-23 15:36:41', null, 'zhangchao', '2015-01-23 15:36:48', null, null);
INSERT INTO `t_task` VALUES ('22', '小时报表4', '1', '1', '不串行，依赖周任务', 'hour', null, '0', '0', '5', '2015-01-23 15:37:13', null, 'zhangchao', '2015-01-23 15:37:20', null, null);
INSERT INTO `t_task` VALUES ('23', '小时报表5', '1', '1', '不串行，依赖月任务', 'hour', null, '0', '0', '5', '2015-01-23 15:37:44', null, 'zhangchao', '2015-01-23 15:37:50', null, null);
INSERT INTO `t_task` VALUES ('24', '小时报表6', '1', '1', '不串行，依赖小时任务', 'hour', null, '0', '0', '5', '2015-01-23 15:38:13', null, 'zhangchao', '2015-01-23 15:38:19', null, null);
INSERT INTO `t_task` VALUES ('25', '10分钟报表', '1', '1', '不串行，无依赖', 'interval', '10', '0', '0', '5', '2015-01-23 15:39:33', null, 'zhangchao', '2015-01-23 15:39:40', null, null);

-- ----------------------------
-- Table structure for `t_task_err`
-- ----------------------------
DROP TABLE IF EXISTS `t_task_err`;
CREATE TABLE `t_task_err` (
  `task_id` int(11) NOT NULL COMMENT '任务ID',
  `run_time` datetime NOT NULL COMMENT '运行时间',
  `group_id` int(11) DEFAULT NULL COMMENT '日志组ID',
  `content` text COMMENT '日志内容',
  `create_time` datetime NOT NULL COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务错误日志';

-- ----------------------------
-- Records of t_task_err
-- ----------------------------

-- ----------------------------
-- Table structure for `t_task_ext`
-- ----------------------------
DROP TABLE IF EXISTS `t_task_ext`;
CREATE TABLE `t_task_ext` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL COMMENT '任务ID',
  `prop_name` varchar(128) NOT NULL COMMENT '属性名',
  `prop_value` text COMMENT '属性值',
  PRIMARY KEY (`id`),
  UNIQUE KEY `task_id` (`task_id`,`prop_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务扩展属性';

-- ----------------------------
-- Records of t_task_ext
-- ----------------------------

-- ----------------------------
-- Table structure for `t_task_history`
-- ----------------------------
DROP TABLE IF EXISTS `t_task_history`;
CREATE TABLE `t_task_history` (
  `task_id` int(11) NOT NULL COMMENT '任务ID',
  `run_time` datetime NOT NULL COMMENT '运行时间',
  `task_state` tinyint(4) NOT NULL DEFAULT '0' COMMENT '任务状态（0:等待，1:就绪，2:正在运行，6:运行成功，9:运行失败）',
  `priority` tinyint(4) NOT NULL DEFAULT '0' COMMENT '任务优先级（值越小优先级越高）',
  `max_try_times` tinyint(4) NOT NULL DEFAULT '5' COMMENT '最多尝试次数',
  `tried_times` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已经尝试次数',
  `redo_flag` tinyint(4) NOT NULL DEFAULT '0' COMMENT '重做标记（1表示重做）',
  `run_server` int(11) DEFAULT NULL COMMENT '运行服务器',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  UNIQUE KEY `task_id` (`task_id`,`run_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务实例';

-- ----------------------------
-- Records of t_task_history
-- ----------------------------

-- ----------------------------
-- Table structure for `t_task_link`
-- ----------------------------
DROP TABLE IF EXISTS `t_task_link`;
CREATE TABLE `t_task_link` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL COMMENT '任务ID',
  `task_pid` int(11) NOT NULL COMMENT '父任务ID',
  `link_type` tinyint(4) NOT NULL DEFAULT '0' COMMENT '依赖类型（0:全周期，1:最后一个周期，2:任意一个周期）',
  `create_user` varchar(64) NOT NULL COMMENT '创建者',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `task_id` (`task_id`,`task_pid`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COMMENT='任务依赖关系';

-- ----------------------------
-- Records of t_task_link
-- ----------------------------
INSERT INTO `t_task_link` VALUES ('1', '3', '1', '0', 'zhangchao', '2015-01-23 15:41:31');
INSERT INTO `t_task_link` VALUES ('2', '9', '1', '0', 'zhangchao', '2015-01-23 15:43:23');
INSERT INTO `t_task_link` VALUES ('3', '10', '7', '0', 'zhangchao', '2015-01-23 15:43:45');
INSERT INTO `t_task_link` VALUES ('4', '15', '1', '0', 'zhangchao', '2015-01-23 15:44:48');
INSERT INTO `t_task_link` VALUES ('5', '17', '13', '0', 'zhangchao', '2015-01-23 15:45:32');
INSERT INTO `t_task_link` VALUES ('6', '24', '19', '0', 'zhangchao', '2015-01-23 15:47:02');

-- ----------------------------
-- Table structure for `t_task_log`
-- ----------------------------
DROP TABLE IF EXISTS `t_task_log`;
CREATE TABLE `t_task_log` (
  `task_id` int(11) NOT NULL COMMENT '任务ID',
  `run_time` datetime NOT NULL COMMENT '运行时间',
  `group_id` int(11) DEFAULT NULL COMMENT '日志组ID',
  `level` tinyint(4) NOT NULL DEFAULT '0' COMMENT '日志级别（0:标准日志，1:警告日志，2:错误日志）',
  `content` text COMMENT '日志内容',
  `create_time` datetime NOT NULL COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务日志';

-- ----------------------------
-- Records of t_task_log
-- ----------------------------

-- ----------------------------
-- Table structure for `t_task_pool`
-- ----------------------------
DROP TABLE IF EXISTS `t_task_pool`;
CREATE TABLE `t_task_pool` (
  `task_id` int(11) NOT NULL COMMENT '任务ID',
  `run_time` datetime NOT NULL COMMENT '运行时间',
  `task_state` tinyint(4) NOT NULL DEFAULT '0' COMMENT '任务状态（0:等待，1:就绪，2:正在运行，6:运行成功，9:运行失败）',
  `priority` tinyint(4) NOT NULL DEFAULT '0' COMMENT '任务优先级（值越小优先级越高）',
  `max_try_times` tinyint(4) NOT NULL DEFAULT '5' COMMENT '最多尝试次数',
  `tried_times` tinyint(4) NOT NULL DEFAULT '0' COMMENT '已经尝试次数',
  `redo_flag` tinyint(4) NOT NULL DEFAULT '0' COMMENT '重做标记（1表示重做）',
  `run_server` int(11) DEFAULT NULL COMMENT '运行服务器',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  UNIQUE KEY `task_id` (`task_id`,`run_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='任务实例';

-- ----------------------------
-- Records of t_task_pool
-- ----------------------------
INSERT INTO `t_task_pool` VALUES ('1', '2015-01-21 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:25', null);
INSERT INTO `t_task_pool` VALUES ('1', '2015-01-22 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:25', null);
INSERT INTO `t_task_pool` VALUES ('1', '2015-01-23 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:29', null);
INSERT INTO `t_task_pool` VALUES ('1', '2015-01-24 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 15:14:39', null);
INSERT INTO `t_task_pool` VALUES ('1', '2015-01-25 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 15:14:09', null);
INSERT INTO `t_task_pool` VALUES ('2', '2015-01-21 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:25', null);
INSERT INTO `t_task_pool` VALUES ('2', '2015-01-22 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:25', null);
INSERT INTO `t_task_pool` VALUES ('2', '2015-01-23 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:30', null);
INSERT INTO `t_task_pool` VALUES ('2', '2015-01-24 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 15:15:40', null);
INSERT INTO `t_task_pool` VALUES ('2', '2015-01-25 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 15:15:12', null);
INSERT INTO `t_task_pool` VALUES ('3', '2015-01-21 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:26', null);
INSERT INTO `t_task_pool` VALUES ('3', '2015-01-22 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:26', null);
INSERT INTO `t_task_pool` VALUES ('3', '2015-01-23 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:30', null);
INSERT INTO `t_task_pool` VALUES ('3', '2015-01-24 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 15:15:41', null);
INSERT INTO `t_task_pool` VALUES ('3', '2015-01-25 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 15:16:14', null);
INSERT INTO `t_task_pool` VALUES ('4', '2015-01-21 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:26', null);
INSERT INTO `t_task_pool` VALUES ('4', '2015-01-22 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:26', null);
INSERT INTO `t_task_pool` VALUES ('4', '2015-01-23 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:30', null);
INSERT INTO `t_task_pool` VALUES ('4', '2015-01-24 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 15:17:44', null);
INSERT INTO `t_task_pool` VALUES ('4', '2015-01-25 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 15:18:20', null);
INSERT INTO `t_task_pool` VALUES ('5', '2015-01-23 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:30', null);
INSERT INTO `t_task_pool` VALUES ('5', '2015-01-24 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 15:18:46', null);
INSERT INTO `t_task_pool` VALUES ('5', '2015-01-25 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 15:18:20', null);
INSERT INTO `t_task_pool` VALUES ('6', '2015-01-21 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:26', null);
INSERT INTO `t_task_pool` VALUES ('6', '2015-01-22 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:26', null);
INSERT INTO `t_task_pool` VALUES ('6', '2015-01-23 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:30', null);
INSERT INTO `t_task_pool` VALUES ('6', '2015-01-24 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 15:27:01', null);
INSERT INTO `t_task_pool` VALUES ('6', '2015-01-25 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 15:26:41', null);
INSERT INTO `t_task_pool` VALUES ('7', '2015-01-07 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:26', null);
INSERT INTO `t_task_pool` VALUES ('7', '2015-01-14 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:26', null);
INSERT INTO `t_task_pool` VALUES ('7', '2015-01-21 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:26', null);
INSERT INTO `t_task_pool` VALUES ('8', '2015-01-06 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:26', null);
INSERT INTO `t_task_pool` VALUES ('8', '2015-01-13 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:27', null);
INSERT INTO `t_task_pool` VALUES ('8', '2015-01-20 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:27', null);
INSERT INTO `t_task_pool` VALUES ('9', '2015-01-07 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:27', null);
INSERT INTO `t_task_pool` VALUES ('9', '2015-01-14 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:27', null);
INSERT INTO `t_task_pool` VALUES ('9', '2015-01-21 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:27', null);
INSERT INTO `t_task_pool` VALUES ('10', '2015-01-07 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:27', null);
INSERT INTO `t_task_pool` VALUES ('10', '2015-01-14 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:27', null);
INSERT INTO `t_task_pool` VALUES ('10', '2015-01-21 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:27', null);
INSERT INTO `t_task_pool` VALUES ('11', '2015-01-06 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:27', null);
INSERT INTO `t_task_pool` VALUES ('11', '2015-01-13 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:27', null);
INSERT INTO `t_task_pool` VALUES ('11', '2015-01-20 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:28', null);
INSERT INTO `t_task_pool` VALUES ('12', '2015-01-07 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:28', null);
INSERT INTO `t_task_pool` VALUES ('12', '2015-01-14 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:28', null);
INSERT INTO `t_task_pool` VALUES ('12', '2015-01-21 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:28', null);
INSERT INTO `t_task_pool` VALUES ('13', '2014-11-05 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:28', null);
INSERT INTO `t_task_pool` VALUES ('13', '2014-12-05 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:28', null);
INSERT INTO `t_task_pool` VALUES ('13', '2015-01-05 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:28', null);
INSERT INTO `t_task_pool` VALUES ('14', '2014-11-08 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:28', null);
INSERT INTO `t_task_pool` VALUES ('14', '2014-12-08 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:28', null);
INSERT INTO `t_task_pool` VALUES ('14', '2015-01-08 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:28', null);
INSERT INTO `t_task_pool` VALUES ('15', '2014-11-07 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:28', null);
INSERT INTO `t_task_pool` VALUES ('15', '2014-12-07 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:29', null);
INSERT INTO `t_task_pool` VALUES ('15', '2015-01-07 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:29', null);
INSERT INTO `t_task_pool` VALUES ('16', '2014-12-07 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:29', null);
INSERT INTO `t_task_pool` VALUES ('16', '2015-01-07 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:29', null);
INSERT INTO `t_task_pool` VALUES ('17', '2014-11-10 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:29', null);
INSERT INTO `t_task_pool` VALUES ('17', '2014-12-10 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:29', null);
INSERT INTO `t_task_pool` VALUES ('17', '2015-01-10 00:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:29', null);
INSERT INTO `t_task_pool` VALUES ('18', '2014-12-10 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:29', null);
INSERT INTO `t_task_pool` VALUES ('18', '2015-01-10 00:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:29', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-23 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:30', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-23 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-23 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 19:00:57', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-23 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 20:00:19', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-23 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 21:00:47', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-23 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 22:00:19', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-23 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 23:00:58', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-24 15:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 15:35:16', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-24 16:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 16:00:01', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-24 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 17:01:01', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-24 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 18:01:01', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-24 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 19:00:04', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-24 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 20:00:13', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-24 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 21:00:30', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-24 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 22:00:55', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-24 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 23:00:20', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-25 15:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 15:36:05', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-25 16:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 16:00:07', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-25 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 17:00:50', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-25 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-25 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 19:00:25', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-25 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 20:00:18', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-25 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 21:00:13', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-25 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 22:00:18', null);
INSERT INTO `t_task_pool` VALUES ('19', '2015-01-25 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 23:00:26', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-23 17:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:30', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-23 18:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-23 19:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 19:00:57', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-23 20:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 20:00:19', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-23 21:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 21:00:48', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-23 22:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 22:00:19', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-23 23:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 23:00:58', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-24 15:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 15:36:18', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-24 16:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 16:00:02', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-24 17:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 17:01:01', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-24 18:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 18:01:01', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-24 19:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 19:00:04', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-24 20:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 20:00:13', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-24 21:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 21:00:30', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-24 22:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 22:00:55', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-24 23:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 23:00:20', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-25 15:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 15:36:05', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-25 16:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 16:00:07', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-25 17:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 17:00:50', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-25 18:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-25 19:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 19:00:25', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-25 20:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 20:00:18', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-25 21:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 21:00:13', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-25 22:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 22:00:19', null);
INSERT INTO `t_task_pool` VALUES ('20', '2015-01-25 23:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 23:00:26', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-23 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:30', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-23 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-23 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 19:00:57', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-23 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 20:00:19', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-23 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 21:00:48', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-23 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 22:00:20', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-23 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 23:00:58', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-24 15:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 15:37:19', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-24 16:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 16:00:02', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-24 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 17:01:01', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-24 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 18:01:02', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-24 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 19:00:04', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-24 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 20:00:13', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-24 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 21:00:30', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-24 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 22:00:55', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-24 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 23:00:20', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-25 15:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 15:37:08', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-25 16:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 16:00:07', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-25 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 17:00:51', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-25 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-25 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 19:00:25', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-25 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 20:00:18', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-25 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 21:00:13', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-25 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 22:00:19', null);
INSERT INTO `t_task_pool` VALUES ('21', '2015-01-25 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 23:00:26', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-23 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:30', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-23 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-23 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 19:00:57', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-23 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 20:00:19', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-23 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 21:00:48', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-23 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 22:00:20', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-23 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 23:00:59', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-24 15:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 15:37:20', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-24 16:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 16:00:02', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-24 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 17:01:01', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-24 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 18:01:02', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-24 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 19:00:04', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-24 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 20:00:13', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-24 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 21:00:30', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-24 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 22:00:55', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-24 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 23:00:20', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-25 15:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 15:38:10', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-25 16:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 16:00:08', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-25 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 17:00:51', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-25 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-25 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 19:00:25', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-25 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 20:00:18', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-25 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 21:00:13', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-25 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 22:00:19', null);
INSERT INTO `t_task_pool` VALUES ('22', '2015-01-25 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 23:00:26', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-23 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:30', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-23 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-23 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 19:00:57', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-23 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 20:00:19', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-23 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 21:00:48', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-23 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 22:00:20', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-23 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-23 23:00:59', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-24 15:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 15:38:22', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-24 16:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 16:00:02', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-24 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 17:01:01', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-24 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 18:01:02', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-24 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 19:00:05', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-24 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 20:00:13', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-24 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 21:00:30', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-24 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 22:00:55', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-24 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-24 23:00:20', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-25 15:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 15:38:10', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-25 16:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 16:00:08', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-25 17:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 17:00:51', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-25 18:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-25 19:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 19:00:25', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-25 20:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 20:00:19', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-25 21:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 21:00:13', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-25 22:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 22:00:19', null);
INSERT INTO `t_task_pool` VALUES ('23', '2015-01-25 23:00:00', '1', '0', '5', '0', '0', null, null, null, '2015-01-25 23:00:26', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-23 17:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 17:05:30', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-23 18:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-23 19:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 19:00:57', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-23 20:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 20:00:20', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-23 21:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 21:00:48', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-23 22:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 22:00:20', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-23 23:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-23 23:00:59', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-24 15:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 15:38:22', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-24 16:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 16:00:02', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-24 17:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 17:01:01', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-24 18:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 18:01:02', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-24 19:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 19:00:05', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-24 20:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 20:00:13', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-24 21:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 21:00:30', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-24 22:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 22:00:55', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-24 23:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-24 23:00:21', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-25 15:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 15:39:13', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-25 16:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 16:00:08', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-25 17:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 17:00:51', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-25 18:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 18:00:38', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-25 19:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 19:00:25', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-25 20:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 20:00:19', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-25 21:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 21:00:13', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-25 22:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 22:00:19', null);
INSERT INTO `t_task_pool` VALUES ('24', '2015-01-25 23:00:00', '0', '0', '5', '0', '0', null, null, null, '2015-01-25 23:00:26', null);

-- ----------------------------
-- Table structure for `t_task_type`
-- ----------------------------
DROP TABLE IF EXISTS `t_task_type`;
CREATE TABLE `t_task_type` (
  `id` smallint(6) NOT NULL AUTO_INCREMENT,
  `code` varchar(64) DEFAULT NULL COMMENT '代码',
  `description` varchar(255) DEFAULT NULL,
  `max_try_times` tinyint(4) NOT NULL DEFAULT '5' COMMENT '最多尝试次数',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='任务类型';

-- ----------------------------
-- Records of t_task_type
-- ----------------------------
INSERT INTO `t_task_type` VALUES ('1', 'mysql2mysql', 'MySQL到MySQL数据同步', '5');
INSERT INTO `t_task_type` VALUES ('2', 'mysql2hive', 'MySQL到Hive数据同步', '5');
INSERT INTO `t_task_type` VALUES ('3', 'hive2mysql', 'Hive到MySQL数据同步', '5');

-- ----------------------------
-- View structure for `v_task_daily`
-- ----------------------------
DROP VIEW IF EXISTS `v_task_daily`;
CREATE ALGORITHM=UNDEFINED DEFINER=`etl`@`%` SQL SECURITY DEFINER VIEW `v_task_daily` AS select `t_task`.`id` AS `task_id`,date_format(curdate(),'%Y%m%d') AS `run_time`,`t_task`.`task_cycle` AS `task_cycle`,`t_task`.`cycle_value` AS `cycle_value`,date_format(`t_task`.`start_time`,'%Y%m%d') AS `start_date`,`t_task`.`date_serial` AS `date_serial`,`t_task`.`priority` AS `priority`,`t_task`.`max_try_times` AS `max_try_times` from `t_task` where ((`t_task`.`task_status` = 1) and (`t_task`.`start_time` <= now()) and ((`t_task`.`end_time` >= now()) or isnull(`t_task`.`end_time`)) and (`t_task`.`task_cycle` = 'day') and (curtime() >= cast(`t_task`.`start_time` as time)) and ((curtime() <= cast(`t_task`.`end_time` as time)) or (cast(`t_task`.`end_time` as time) = 0) or isnull(`t_task`.`end_time`)) and (not((`t_task`.`id`,curdate()) in (select `t_task_pool`.`task_id`,cast(`t_task_pool`.`run_time` as date) from `t_task_pool` where (`t_task_pool`.`run_time` >= curdate()))))) ;

-- ----------------------------
-- View structure for `v_task_history`
-- ----------------------------
DROP VIEW IF EXISTS `v_task_history`;
CREATE ALGORITHM=UNDEFINED DEFINER=`etl`@`%` SQL SECURITY DEFINER VIEW `v_task_history` AS select `a`.`id` AS `task_id`,`a`.`task_cycle` AS `task_cycle`,`a`.`cycle_value` AS `cycle_value`,date_format(ifnull(max((`b`.`run_time` + interval 1 day)),`a`.`start_time`),'%Y%m%d') AS `start_date`,date_format(if((`a`.`end_time` < now()),`a`.`end_time`,(curdate() - interval 1 day)),'%Y%m%d') AS `end_date`,`a`.`date_serial` AS `date_serial`,`a`.`priority` AS `priority`,`a`.`max_try_times` AS `max_try_times` from (`t_task` `a` left join `t_task_pool` `b` on((`a`.`id` = `b`.`task_id`))) where ((`a`.`task_status` = 1) and (`a`.`start_time` < now()) and (`a`.`task_cycle` in ('day','week','month'))) group by 1 having (isnull(max(`b`.`run_time`)) or (max(`b`.`run_time`) < (curdate() - interval 1 day))) ;

-- ----------------------------
-- View structure for `v_task_hourly`
-- ----------------------------
DROP VIEW IF EXISTS `v_task_hourly`;
CREATE ALGORITHM=UNDEFINED DEFINER=`etl`@`%` SQL SECURITY DEFINER VIEW `v_task_hourly` AS select `t_task`.`id` AS `task_id`,date_format(now(),'%Y%m%d%H') AS `run_time`,`t_task`.`task_cycle` AS `task_cycle`,`t_task`.`cycle_value` AS `cycle_value`,date_format(`t_task`.`start_time`,'%Y%m%d') AS `start_date`,`t_task`.`date_serial` AS `date_serial`,`t_task`.`priority` AS `priority`,`t_task`.`max_try_times` AS `max_try_times` from `t_task` where ((`t_task`.`task_status` = 1) and (`t_task`.`start_time` <= now()) and ((`t_task`.`end_time` >= now()) or isnull(`t_task`.`end_time`)) and (`t_task`.`task_cycle` = 'hour') and (curtime() >= cast(`t_task`.`start_time` as time)) and ((curtime() <= cast(`t_task`.`end_time` as time)) or (cast(`t_task`.`end_time` as time) = 0) or isnull(`t_task`.`end_time`)) and ((date_format(now(),'%H') like concat('%',`t_task`.`cycle_value`,'%')) or isnull(`t_task`.`cycle_value`)) and (not((`t_task`.`id`,date_format(now(),'%Y-%m-%d %H')) in (select `t_task_pool`.`task_id`,date_format(`t_task_pool`.`run_time`,'%Y-%m-%d %H') from `t_task_pool` where (`t_task_pool`.`run_time` >= curdate()))))) ;

-- ----------------------------
-- View structure for `v_task_interval`
-- ----------------------------
DROP VIEW IF EXISTS `v_task_interval`;
CREATE ALGORITHM=UNDEFINED DEFINER=`etl`@`%` SQL SECURITY DEFINER VIEW `v_task_interval` AS select `a`.`task_id` AS `task_id`,if((`b`.`task_cycle` = 'hour'),date_format(`a`.`run_time`,'%Y%m%d%H'),date_format(`a`.`run_time`,'%Y%m%d')) AS `run_time`,`b`.`type_id` AS `task_type_id` from ((`t_task_pool` `a` join `t_task` `b` on(((`a`.`task_id` = `b`.`id`) and (`a`.`task_state` in (1,4)) and (`a`.`tried_times` < `a`.`max_try_times`)))) join `t_task_type` `c` on((`b`.`type_id` = `c`.`id`))) order by `a`.`priority` ;

-- ----------------------------
-- View structure for `v_task_monthly`
-- ----------------------------
DROP VIEW IF EXISTS `v_task_monthly`;
CREATE ALGORITHM=UNDEFINED DEFINER=`etl`@`%` SQL SECURITY DEFINER VIEW `v_task_monthly` AS select `t_task`.`id` AS `task_id`,date_format(curdate(),'%Y%m%d') AS `run_time`,`t_task`.`task_cycle` AS `task_cycle`,`t_task`.`cycle_value` AS `cycle_value`,date_format(`t_task`.`start_time`,'%Y%m%d') AS `start_date`,`t_task`.`date_serial` AS `date_serial`,`t_task`.`priority` AS `priority`,`t_task`.`max_try_times` AS `max_try_times` from `t_task` where ((`t_task`.`task_status` = 1) and (`t_task`.`start_time` <= now()) and ((`t_task`.`end_time` >= now()) or isnull(`t_task`.`end_time`)) and (`t_task`.`task_cycle` = 'month') and (curtime() >= cast(`t_task`.`start_time` as time)) and ((curtime() <= cast(`t_task`.`end_time` as time)) or (cast(`t_task`.`end_time` as time) = 0) or isnull(`t_task`.`end_time`)) and (dayofmonth(curdate()) = `t_task`.`cycle_value`) and (not((`t_task`.`id`,curdate()) in (select `t_task_pool`.`task_id`,cast(`t_task_pool`.`run_time` as date) from `t_task_pool` where (`t_task_pool`.`run_time` >= curdate()))))) ;

-- ----------------------------
-- View structure for `v_task_ready`
-- ----------------------------
DROP VIEW IF EXISTS `v_task_ready`;
CREATE ALGORITHM=UNDEFINED DEFINER=`etl`@`%` SQL SECURITY DEFINER VIEW `v_task_ready` AS select `a`.`task_id` AS `task_id`,if((`b`.`task_cycle` = 'hour'),date_format(`a`.`run_time`,'%Y%m%d%H'),date_format(`a`.`run_time`,'%Y%m%d')) AS `run_time`,`b`.`type_id` AS `task_type_id` from ((`t_task_pool` `a` join `t_task` `b` on(((`a`.`task_id` = `b`.`id`) and (`a`.`task_state` in (1,4)) and (`a`.`tried_times` < `a`.`max_try_times`)))) join `t_task_type` `c` on((`b`.`type_id` = `c`.`id`))) order by `a`.`priority` ;

-- ----------------------------
-- View structure for `v_task_wait`
-- ----------------------------
DROP VIEW IF EXISTS `v_task_wait`;
CREATE ALGORITHM=UNDEFINED DEFINER=`etl`@`%` SQL SECURITY DEFINER VIEW `v_task_wait` AS select `a`.`task_id` AS `task_id`,if((`b`.`task_cycle` = 'hour'),date_format(`a`.`run_time`,'%Y%m%d%H'),date_format(`a`.`run_time`,'%Y%m%d')) AS `run_time`,`b`.`task_cycle` AS `task_cycle`,`b`.`cycle_value` AS `cycle_value`,date_format(`b`.`start_time`,'%Y%m%d') AS `start_date`,`b`.`date_serial` AS `date_serial` from (`t_task_pool` `a` join `t_task` `b` on(((`a`.`task_id` = `b`.`id`) and (`a`.`task_state` = 0)))) ;

-- ----------------------------
-- View structure for `v_task_weekly`
-- ----------------------------
DROP VIEW IF EXISTS `v_task_weekly`;
CREATE ALGORITHM=UNDEFINED DEFINER=`etl`@`%` SQL SECURITY DEFINER VIEW `v_task_weekly` AS select `t_task`.`id` AS `task_id`,date_format(curdate(),'%Y%m%d') AS `run_time`,`t_task`.`task_cycle` AS `task_cycle`,`t_task`.`cycle_value` AS `cycle_value`,date_format(`t_task`.`start_time`,'%Y%m%d') AS `start_date`,`t_task`.`date_serial` AS `date_serial`,`t_task`.`priority` AS `priority`,`t_task`.`max_try_times` AS `max_try_times` from `t_task` where ((`t_task`.`task_status` = 1) and (`t_task`.`start_time` <= now()) and ((`t_task`.`end_time` >= now()) or isnull(`t_task`.`end_time`)) and (`t_task`.`task_cycle` = 'week') and (curtime() >= cast(`t_task`.`start_time` as time)) and ((curtime() <= cast(`t_task`.`end_time` as time)) or (cast(`t_task`.`end_time` as time) = 0) or isnull(`t_task`.`end_time`)) and ((weekday(curdate()) + 1) = `t_task`.`cycle_value`) and (not((`t_task`.`id`,curdate()) in (select `t_task_pool`.`task_id`,cast(`t_task_pool`.`run_time` as date) from `t_task_pool` where (`t_task_pool`.`run_time` >= curdate()))))) ;
