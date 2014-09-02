require.register("config.jsenv", function(exports, require, module){
    module.exports = {
  "BUILD": "git-unknown",
  "APIENDPOINT": "http://api.ly.g0v.tw/"
}
});
angular.module('ly.g0v.tw', ['ngGrid', 'app.controllers', 'ly.g0v.tw.controllers', 'app.directives', 'app.filters', 'app.services', 'app.templates', 'ui.state', 'utils', 'monospaced.qrcode']).config(['$stateProvider', '$urlRouterProvider', '$locationProvider'].concat(function($stateProvider, $urlRouterProvider, $locationProvider){
  $stateProvider.state('motions', {
    url: '/motions',
    templateUrl: 'app/partials/motions.html',
    controller: 'LYMotions'
  }).state('motions.sitting', {
    url: '/{session}/{sitting}'
  }).state('sittings-new', {
    url: '/sittings-new/{sittingId}',
    templateUrl: 'app/partials/sittings-new.html',
    resolve: {
      _init: ['LYService'].concat(function(it){
        return it.init();
      })
    },
    controller: 'LYSittingsNew'
  }).state('bills', {
    url: '/bills',
    templateUrl: 'app/partials/bills-hot.html',
    resolve: {
      _init: ['LYService'].concat(function(it){
        return it.init();
      })
    },
    controller: 'LYBillsIndex'
  }).state('bills-detail', {
    url: '/bills/{billId}',
    templateUrl: 'app/partials/bills.html',
    resolve: {
      _init: ['LYService'].concat(function(it){
        return it.init();
      })
    },
    controller: 'LYBills'
  }).state('bills-detail.compare', {
    url: '/compare/{otherBills}'
  }).state('calendar', {
    url: '/calendar',
    templateUrl: 'app/partials/calendar.html',
    resolve: {
      _init: ['LYService'].concat(function(it){
        return it.init();
      })
    },
    controller: 'LYCalendar'
  }).state('calendar.period', {
    url: '/{period}'
  }).state('sittings', {
    url: '/sittings',
    templateUrl: 'app/partials/sittings.html',
    controller: 'LYSittings',
    resolve: {
      _init: ['LYService'].concat(function(it){
        return it.init();
      })
    }
  }).state('sittings.detail', {
    url: '/{sitting}'
  }).state('sittings.detail.video', {
    url: '/video'
  }).state('debates', {
    url: '/debates',
    templateUrl: 'app/partials/debates.html',
    resolve: {
      _init: ['LYService'].concat(function(it){
        return it.init();
      })
    }
  }).state('search', {
    url: '/search',
    templateUrl: 'app/partials/search.html',
    controller: 'LYSearch'
  }).state('search.target', {
    url: '/{keyword}'
  }).state('about', {
    url: '/about',
    templateUrl: 'app/partials/about.html',
    controller: 'About'
  });
  $urlRouterProvider.otherwise('/calendar');
  return $locationProvider.html5Mode(true);
})).run(['$rootScope', '$state', '$stateParams', '$location', '$window', '$anchorScroll'].concat(function($rootScope, $state, $stateParams, $location, $window, $anchorScroll){
  var checkMobile;
  $rootScope.$state = $state;
  $rootScope.$stateParam = $stateParams;
  $rootScope.go = function(it){
    return $location.path(it);
  };
  $rootScope.config_build = require('config.jsenv').BUILD;
  $rootScope.$on('$stateChangeSuccess', function(e, arg$){
    var name;
    name = arg$.name;
    return typeof window != 'undefined' && window !== null ? typeof window.ga === 'function' ? window.ga('send', 'pageview', {
      page: $location.$$path,
      title: name
    }) : void 8 : void 8;
  });
  window.onYouTubeIframeAPIReady = function(){
    return $rootScope.$broadcast('youtube-ready');
  };
  checkMobile = function(){
    var width;
    width = $($window).width();
    return $rootScope.isMobile = width <= 768;
  };
  $($window).resize(function(){
    return $rootScope.$apply(checkMobile);
  });
  return checkMobile();
}));
var parseArticleHeading, notAnArticle, billAmendment, diffmeta, Steps, AugmentedString, slice$ = [].slice, replace$ = ''.replace;
parseArticleHeading = function(text){
  var ref$, _, _items, zhutil;
  if ((ref$ = text.match(/第(.+)之(.+)條/) || text.match(/第(.+)條(?:之(.+))?/)) != null) {
    _ = ref$[0], _items = slice$.call(ref$, 1);
  }
  if (!_items) {
    return text;
  }
  zhutil = require('zhutil');
  return _items.filter(function(it){
    return it;
  }).map(zhutil.parseZHNumber).join('-');
};
notAnArticle = /^(（\S+）\n|)第\S+(章|編|節)/;
billAmendment = function(diff, idx, c, baseIndex){
  return function(entry){
    var h, comment, baseTextLines, that, originalArticle, newTextLines, article;
    h = diff.header;
    comment = 'string' === typeof entry[c]
      ? entry[c]
      : entry[c][h[idx].replace(/審查會通過條文/, '審查會')];
    if (comment) {
      comment = comment.replace(/\n/g, "<br><br>\n");
    }
    baseTextLines = entry[baseIndex] || '';
    if (baseTextLines) {
      baseTextLines = replace$.call(baseTextLines, /^第(.*?)(條(之.*?)?|章|篇|節)\s+/, '');
      if (that = parseArticleHeading(replace$.call(RegExp.lastMatch, /\s+$/, ''))) {
        originalArticle = that;
      }
    }
    newTextLines = entry[idx] || entry[baseIndex] || '';
    newTextLines = replace$.call(newTextLines, /^第(.*?)(條(之.*?)?|章|篇|節)\s+/, '');
    article = parseArticleHeading(replace$.call(RegExp.lastMatch, /\s+$/, ''));
    if (!originalArticle) {
      if (newTextLines.match(/^（\S+）\n第(.*?)條/) || newTextLines.match(/^（\S+第(.*?)條，保留）/)) {
        article = parseArticleHeading(replace$.call(RegExp.lastMatch, /\s+$/, ''));
      }
      if (newTextLines.match(notAnArticle)) {
        article = newTextLines.replace(/^（\S+）\n/, '').split('　')[0];
      } else {
        originalArticle = article || '';
      }
    }
    return {
      comment: comment,
      article: article,
      originalArticle: originalArticle,
      content: newTextLines,
      baseContent: baseTextLines
    };
  };
};
diffmeta = function(content){
  return content != null ? content.map(function(diff){
    var h, i, n, baseIndex, c;
    if (!diff.name) {
      diff.name = '併案審議';
    }
    h = diff.header;
    baseIndex = (function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = h).length; i$ < len$; ++i$) {
        i = i$;
        n = ref$[i$];
        if (/^現行/.exec(n)) {
          results$.push(i);
        }
      }
      return results$;
    }())[0];
    c = (function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = h).length; i$ < len$; ++i$) {
        i = i$;
        n = ref$[i$];
        if (n === '說明') {
          results$.push(i);
        }
      }
      return results$;
    }())[0];
    return import$({
      header: diff.header,
      content: diff.content,
      name: diff.name
    }, {
      versions: h.filter(function(it, i){
        return it !== '說明' && i !== baseIndex;
      }),
      baseIndex: baseIndex,
      commentIndex: c,
      diffbase: h[baseIndex],
      diffnew: h[0],
      amendment: diff.content.map(billAmendment(diff, 0, c, baseIndex))
    });
  }) : void 8;
};
Steps = (function(){
  Steps.displayName = 'Steps';
  var prototype = Steps.prototype, constructor = Steps;
  function Steps(bill, lymodel, scope){
    this.bill = bill;
    this.lymodel = lymodel;
    this.scope = scope;
    this.proposal = {
      sub: false,
      desc: "提案",
      icon: "",
      status: "passed",
      date: '?.?.?',
      detail: []
    };
    this.first_reading = {
      sub: false,
      desc: "一讀",
      icon: "comment",
      status: "scheduled",
      date: '?.?.?',
      detail: []
    };
    this.committee = {
      sub: false,
      desc: "付委",
      icon: "chat",
      status: "not-yet",
      date: '?.?.?',
      detail: []
    };
    this.second_reading = {
      sub: false,
      desc: "二讀",
      icon: "chat",
      status: "not-yet",
      date: '?.?.?',
      detail: []
    };
    this.third_reading = {
      sub: false,
      desc: "三讀",
      icon: "chat",
      status: "not-yet",
      date: '?.?.?',
      detail: []
    };
    this.announced = {
      sub: false,
      desc: "頒佈",
      icon: "unmute",
      status: "not-yet",
      date: '?.?.?',
      detail: []
    };
    this.implemented = {
      sub: false,
      desc: "生效",
      icon: "legal",
      status: "not-yet",
      date: '?.?.?',
      detail: []
    };
  }
  prototype.build = function(cb){
    if (this.step) {
      return this.step;
    }
    this.build_from_motions();
    return this.build_from_report(function(self){
      return self.build_from_ttsmotions(function(self){
        self.steps = [self.proposal, self.first_reading, self.committee, self.second_reading, self.third_reading, self.announced, self.implemented];
        self.ensure_steps_status_order();
        self.ensure_only_one_scheduled_step();
        self.set_proposal_icon_if_bill_has_been_rejected();
        self.set_proposal_date_if_first_reading_has_date();
        return cb(self.steps);
      });
    });
  };
  prototype.build_from_motions = function(){
    var motions, i$, len$, motion, desc, date, ref$, results$ = [];
    motions = this.bill.motions.filter(function(it){
      return it.resolution !== null;
    });
    for (i$ = 0, len$ = motions.length; i$ < len$; ++i$) {
      motion = motions[i$];
      desc = motion.resolution;
      date = this.pretty_date(motion.dates[0].date);
      switch (false) {
      case !desc.match(/少數不通過|退回程序委員會/):
        ref$ = this.proposal;
        ref$.status = 'passed';
        ref$.date = date;
        ref$.detail = [{
          desc: desc,
          date: date
        }];
        results$.push((ref$ = this.first_reading, ref$.status = 'scheduled', ref$));
        break;
      case !desc.match(/交([^，]+?)[兩三四五六七八]?委員會|中央政府總預算案/):
        this.proposal.status = 'passed';
        ref$ = this.first_reading;
        ref$.status = 'passed';
        ref$.date = date;
        this.first_reading.detail.push({
          desc: desc,
          date: date
        });
        results$.push((ref$ = this.committee, ref$.status = 'scheduled', ref$));
        break;
      case !desc.match(/展延審查期限/):
        this.proposal.status = 'passed';
        this.first_reading.status = 'passed';
        ref$ = this.committee;
        ref$.status = 'scheduled';
        ref$.date = date;
        results$.push(this.committee.detail.push({
          desc: desc,
          date: date
        }));
        break;
      case !desc.match(/逕付(院會)?二讀/):
        this.proposal.status = 'passed';
        ref$ = this.first_reading;
        ref$.status = 'passed';
        ref$.date = date;
        this.first_reading.detail.push({
          desc: desc,
          date: date
        });
        this.committee.status = 'passed';
        results$.push((ref$ = this.second_reading, ref$.status = 'scheduled', ref$));
        break;
      case !desc.match(/同意撤回/):
        this.proposal.status = 'passed';
        this.first_reading.status = 'passed';
        this.committee.status = 'passed';
        ref$ = this.second_reading;
        ref$.status = 'passed';
        ref$.date = date;
        results$.push(this.second_reading.detail.push({
          desc: desc,
          date: date
        }));
      }
    }
    return results$;
  };
  prototype.build_from_report = function(cb){
    var self;
    self = this;
    return this.report_of_bill(this.bill, function(func){
      func['finally'](function(report){
        return cb(self);
      });
      return func.success(function(report){
        var date, ref$;
        self.scope.report = report;
        date = self.pretty_date(report.motions[0].dates[0].date);
        ref$ = self.committee;
        ref$.status = "passed";
        ref$.date = date;
        self.committee.detail.push({
          desc: report.summary,
          date: date
        });
        return import$(self.second_reading, !/審查決議：「不予審議」/.test(report.summary) ? {
          status: "scheduled"
        } : void 8);
      });
    });
  };
  prototype.report_of_bill = function(bill, cb){
    var func;
    func = this.lymodel.get("bills", {
      params: {
        q: JSON.stringify({
          report_of: {
            $contains: bill.bill_id
          }
        }),
        fo: true
      }
    });
    return cb(func);
  };
  prototype.build_from_ttsmotions = function(cb){
    var self;
    if (/-/.exec(this.bill.bill_ref)) {
      return cb(this);
    }
    self = this;
    return this.get_ttsmotions(function(ttsmotions){
      var prev_step, i$, len$, motion, step;
      self.scope.ttsmotions = ttsmotions;
      for (i$ = 0, len$ = ttsmotions.length; i$ < len$; ++i$) {
        motion = ttsmotions[i$];
        motion.links = self.links_of_ttsmotion(motion);
        step = self.step_of_ttsmotion(prev_step, motion);
        self.update_step_by_ttsmotion(prev_step, step, motion);
        self.update_detail_by_ttsmotion(step.detail, motion);
        prev_step = step;
      }
      return cb(self);
    });
  };
  prototype.get_ttsmotions = function(cb){
    return this.lymodel.get("ttsmotions", {
      params: {
        s: {
          date: -1
        },
        q: JSON.stringify({
          bill_refs: {
            $contains: this.bill.bill_ref
          }
        })
      }
    }).success(function(arg$){
      var ttsmotions;
      ttsmotions = arg$.entries;
      return cb(ttsmotions.reverse());
    });
  };
  prototype.links_of_ttsmotion = function(ttsmotion){
    var desc, links;
    desc = new AugmentedString(ttsmotion.resolution);
    links = desc.scan(/([\d-]+)\s\["(\w+)",(\d+),(\d+),(\d+),(\d+),(\d+)\]/);
    links = links.filter(function(link){
      return link[1] === 'g';
    });
    return links.map(function(link){
      var text, vol, url;
      text = 'p. ' + link[0];
      vol = new AugmentedString(link[2]).rjust(3, '0');
      vol += new AugmentedString(link[3]).rjust(3, '0');
      vol += new AugmentedString(link[4]).rjust(2, '0');
      url = "http://lis.ly.gov.tw/lgcgi/lypdftxt?" + vol + ";" + link[5] + ";" + link[6];
      return {
        text: text,
        link: url
      };
    });
  };
  prototype.step_of_ttsmotion = function(prev_step, ttsmotion){
    var process, desc;
    process = ttsmotion.progress;
    desc = ttsmotion.resolution;
    switch (false) {
    case process !== '復議(另定期處理)':
      switch (false) {
      case prev_step !== this.first_reading:
        return this.first_reading;
      case prev_step !== this.committee:
        return this.committee;
      case prev_step !== this.third_reading:
        return this.third_reading;
      }
      break;
    case !/提案|退回程序/.test(process):
      return this.proposal;
    case !/一讀/.test(process):
      return this.first_reading;
    case process !== '委員會':
      return this.committee;
    case !/黨團協商/.test(process):
      return this.second_reading;
    case !/二讀/.test(process):
      if (/逕付(院會)?二讀/.exec(desc)) {
        return this.first_reading;
      } else {
        return this.second_reading;
      }
      break;
    case process !== '撤回':
      return this.second_reading;
    case !/三讀/.test(process):
      return this.third_reading;
    case !/覆議/.test(process):
      return this.third_reading;
    case !/頒佈/.test(process):
      return this.announced;
    case !/生效/.test(process):
      return this.implemented;
    case process !== null:
      switch (false) {
      case !/另定期繼審審查/.test(desc):
        return this.committee;
      case !/交黨團進行協商/.test(desc):
        return this.second_reading;
      }
    }
  };
  prototype.update_step_by_ttsmotion = function(prev_step, step, ttsmotion){
    var date, process, desc, ref$;
    date = this.date_of_ttsmotion(ttsmotion);
    process = ttsmotion.progress;
    desc = ttsmotion.resolution;
    switch (false) {
    case process !== '復議(另定期處理)':
      switch (false) {
      case prev_step !== this.first_reading:
        return ref$ = this.first_reading, ref$.date = date, ref$;
      case prev_step !== this.committee:
        return ref$ = this.committee, ref$.date = date, ref$;
      case prev_step !== this.third_reading:
        return ref$ = this.third_reading, ref$.date = date, ref$;
      }
      break;
    case !/交([^，]+?)[兩三四五六七八]?委員會|中央政府總預算案/.test(desc):
      this.proposal.status = 'passed';
      ref$ = this.first_reading;
      ref$.status = 'passed';
      ref$.date = date;
      return ref$ = this.committee, ref$.status = 'scheduled', ref$;
    case !/逕付(院會)?二讀/.test(desc):
      break;
    case !/另定期繼審審查/.test(desc):
      this.proposal.status = 'passed';
      this.first_reading.status = 'passed';
      return ref$ = this.committee, ref$.status = 'scheduled', ref$.date = date, ref$;
    case !/二讀/.test(process):
      this.committee.status = 'passed';
      ref$ = this.second_reading;
      ref$.status = 'passed';
      ref$.date = date;
      return ref$ = this.third_reading, ref$.status = 'scheduled', ref$;
    case !/覆議/.test(process):
      this.committee.status = 'passed';
      this.second_reading.status = 'passed';
      if (/覆議案通過/.exec(desc)) {
        ref$ = this.third_reading;
        ref$.status = 'scheduled';
        ref$.date = date;
        return ref$ = this.announced, ref$.status = 'not-yet', ref$;
      } else {
        ref$ = this.third_reading;
        ref$.status = 'passed';
        ref$.date = date;
        return ref$ = this.announced, ref$.status = 'scheduled', ref$;
      }
      break;
    case !/三讀/.test(process):
      this.committee.status = 'passed';
      this.second_reading.status = 'passed';
      ref$ = this.third_reading;
      ref$.status = 'passed';
      ref$.date = date;
      return ref$ = this.announced, ref$.status = 'scheduled', ref$;
    }
  };
  prototype.update_detail_by_ttsmotion = function(detail, ttsmotion){
    var date, desc, links, steps, step;
    date = this.date_of_ttsmotion(ttsmotion);
    desc = this.desc_of_ttsmotion(ttsmotion);
    links = ttsmotion.links;
    steps = this.substeps_of_detail(detail);
    step = steps[date + desc];
    if (step) {
      return step.links = links, step;
    } else {
      return detail.push({
        date: date,
        desc: desc,
        links: links
      });
    }
  };
  prototype.date_of_ttsmotion = function(ttsmotion){
    return moment(ttsmotion.date).format('YYYY.MM.DD');
  };
  prototype.desc_of_ttsmotion = function(ttsmotion){
    var desc;
    desc = ttsmotion.resolution;
    desc = desc.replace(/\(\S+\s+\S+\)/, '');
    desc = desc.replace(/\s/g, '');
    return desc;
  };
  prototype.substeps_of_detail = function(detail){
    var steps, i$, len$, step, date, desc;
    steps = {};
    for (i$ = 0, len$ = detail.length; i$ < len$; ++i$) {
      step = detail[i$];
      date = step.date;
      desc = step.desc.replace(/\決定：|\s/g, '');
      steps[date + desc] = step;
    }
    return steps;
  };
  prototype.pretty_date = function(date){
    return date.replace(/-/g, '.');
  };
  prototype.first_step_has_date = function(){
    var steps;
    steps = this.steps.filter(function(it){
      return it.date !== '?.?.?';
    });
    return steps[0];
  };
  prototype.step_with_elapsed = function(step){
    var parts, ref$, year, month, day, date, now, diff, diffYear, diffMonth, diffDay;
    if (step) {
      parts = step.date.match(/(\d+)\.(\d+)\.(\d+)/);
      ref$ = parts.slice(1), year = ref$[0], month = ref$[1], day = ref$[2];
      date = new Date(year, month, day);
      now = new Date;
      diff = new Date(now.getTime() - date.getTime());
      diffYear = this.pretty_diff('年', diff.getUTCFullYear() - 1970);
      diffMonth = this.pretty_diff('個月', diff.getUTCMonth());
      diffDay = this.pretty_diff('天', diff.getUTCDate() - 1);
      return {
        diffDesc: step.desc,
        diffYear: diffYear,
        diffMonth: diffMonth,
        diffDay: diffDay
      };
    } else {
      return {};
    }
  };
  prototype.pretty_diff = function(unit, number){
    if (number === 0) {
      return '';
    } else {
      return number + " " + unit;
    }
  };
  prototype.ensure_steps_status_order = function(){
    var status, statuses, priorities, i$, ref$, len$, step, priority, results$ = [];
    status = this.steps[0].status;
    statuses = ['passed', 'scheduled', 'not-yet'];
    priorities = {
      passed: 0,
      scheduled: 1,
      'not-yet': 2
    };
    for (i$ = 0, len$ = (ref$ = this.steps).length; i$ < len$; ++i$) {
      step = ref$[i$];
      priority = Math.max.apply(null, [priorities[step.status], priorities[status]]);
      status = statuses[priority];
      results$.push(step.status = status);
    }
    return results$;
  };
  prototype.ensure_only_one_scheduled_step = function(){
    var prev, i$, ref$, len$, step, results$ = [];
    prev = this.steps[0];
    for (i$ = 0, len$ = (ref$ = this.steps).length; i$ < len$; ++i$) {
      step = ref$[i$];
      if (step.status === 'scheduled' && 'scheduled' === prev.status) {
        prev.status = 'passed';
      }
      results$.push(prev = step);
    }
    return results$;
  };
  prototype.set_proposal_icon_if_bill_has_been_rejected = function(){
    this.proposal = this.steps[0];
    if (this.proposal.date !== '?.?.?') {
      return this.proposal.icon = 'exclamation';
    }
  };
  prototype.set_proposal_date_if_first_reading_has_date = function(){
    var ref$;
    ref$ = this.steps, this.proposal = ref$[0], this.first_reading = ref$[1];
    if (this.proposal.date === '?.?.?') {
      return this.proposal.date = this.first_reading.date;
    }
  };
  return Steps;
}());
AugmentedString = (function(){
  AugmentedString.displayName = 'AugmentedString';
  var prototype = AugmentedString.prototype, constructor = AugmentedString;
  function AugmentedString(string){
    this.string = string;
  }
  prototype.scan = function(pattern){
    var ary, string, result, i, item;
    ary = [];
    string = this.string;
    while (result = string.match(pattern)) {
      i = string.indexOf(result[0]);
      string = string.slice(i + result[0].length);
      item = result.length === 1
        ? result[0]
        : result.slice(1);
      ary.push(item);
    }
    return ary;
  };
  prototype.rjust = function(width, padding){
    var len, times, remain, string, tail;
    padding == null && (padding = ' ');
    len = width - this.string.length;
    if (len > 0) {
      times = len / padding.length;
      remain = len % padding.length;
      string = new AugmentedString(padding);
      string = string.repeat(times);
      tail = padding.slice(0, remain);
      string = string.concat(tail);
      return string.concat(this.string);
    } else {
      return this.string;
    }
  };
  prototype.repeat = function(times){
    var clone, i$, to$, i;
    clone = '';
    for (i$ = 0, to$ = times - 1; i$ <= to$; ++i$) {
      i = i$;
      clone = clone.concat(this.string);
    }
    return clone;
  };
  return AugmentedString;
}());
angular.module('app.controllers.bills', ['ly.diff', 'ly.spy']).controller({
  LYBillsIndex: ['$scope', '$state', '$timeout', 'LYService', 'LYModel', '$sce', '$anchorScroll', 'TWLYService'].concat(function($scope, $state, $timeout, LYService, LYModel, $sce, $anchorScroll, TWLYService){
    $scope.currentTab = '1';
    return LYModel.get("analytics", {
      params: {
        q: JSON.stringify({
          name: 'bill'
        })
      }
    }).success(function(arg$){
      $scope.billStats = arg$.entries;
      return $scope.$watch('currentTab', function(it){
        var ref$, e, selected, bill_ref, count, i$, len$, bill;
        if ((ref$ = (function(){
          var i$, ref$, len$, results$ = [];
          for (i$ = 0, len$ = (ref$ = $scope.billStats).length; i$ < len$; ++i$) {
            e = ref$[i$];
            if (e.timeframe === it) {
              results$.push(e);
            }
          }
          return results$;
        }())) != null) {
          selected = ref$[0];
        }
        selected.bills == null && (selected.bills = (function(){
          var i$, ref$, len$, ref1$, results$ = [];
          for (i$ = 0, len$ = (ref$ = selected.content).length; i$ < len$; ++i$) {
            ref1$ = ref$[i$], bill_ref = ref1$[0], count = ref1$[1];
            results$.push({
              bill_ref: bill_ref,
              count: count
            });
          }
          return results$;
        }()));
        for (i$ = 0, len$ = (ref$ = selected.bills).length; i$ < len$; ++i$) {
          bill = ref$[i$];
          if (!bill.sponsors) {
            (fn$.call(this, bill));
          }
        }
        return $scope.currentBills = selected.bills;
        function fn$(bill){
          LYModel.get("bills/" + bill.bill_ref).success(function(billDetails){
            var steps;
            import$(bill, billDetails);
            steps = new Steps(bill, LYModel, {});
            return steps.build(function(stepsDetail){
              var step;
              bill.steps = stepsDetail;
              step = steps.first_step_has_date();
              return import$(bill, steps.step_with_elapsed(step));
            });
          });
        }
      });
    });
  })
}).controller({
  LYBills: ['$scope', '$state', '$timeout', 'LYService', 'LYModel', '$sce', '$anchorScroll', 'TWLYService'].concat(function($scope, $state, $timeout, LYService, LYModel, $sce, $anchorScroll, TWLYService){
    $scope.diffs = [];
    $scope.opts = {
      show_date: true
    };
    $scope.spies = {};
    $scope.found = 'unknown';
    return $scope.$watch('$state.params.billId', function(){
      var billId, req;
      billId = $state.params.billId;
      req = LYModel.get("bills/" + billId);
      req.error(function(){
        return $scope.found = 'no';
      });
      return req.success(function(bill){
        var committee, that, steps, ref$;
        committee = bill.committee;
        $scope.found = 'yes';
        $state.current.title = "國會大代誌 - " + (bill.bill_ref || bill.bill_id) + " - " + bill.summary;
        if (that = bill.bill_ref) {
          if (that !== billId && !/;/.test(that)) {
            return $state.transitionTo('bills', {
              billId: bill.bill_ref
            });
          }
          steps = new Steps(bill, LYModel, $scope);
          steps.build(function(it){
            return $scope.steps = it;
          });
          LYModel.get("bills/" + billId + "/data").success(function(data){
            var ref$, totalEntries;
            $scope.diff = diffmeta(data != null ? data.content : void 8);
            if ((ref$ = $scope.diff) != null && ref$.length) {
              totalEntries = $scope.diff.map(function(it){
                return it.content.length;
              }).reduce(curry$(function(x$, y$){
                return x$ + y$;
              }));
            }
            $scope.showSidebar = totalEntries > 3;
            return $timeout($anchorScroll);
          });
        }
        if (committee != null) {
          committee = committee.map(function(it){
            return {
              abbr: it,
              name: committees[it]
            };
          });
        }
        (ref$ = ($scope.summary = bill.summary, $scope.abstract = bill.abstract, $scope.bill_id = bill.bill_id, $scope.bill_ref = bill.bill_ref, $scope.doc = bill.doc, $scope.sponsors = bill.sponsors, $scope.cosponsors = bill.cosponsors, $scope), ref$.committee = committee, ref$).setDiff = function(diff, version){
          var i, n, idx, baseIndex, c, amendment;
          idx = (function(){
            var i$, ref$, len$, results$ = [];
            for (i$ = 0, len$ = (ref$ = diff.header).length; i$ < len$; ++i$) {
              i = i$;
              n = ref$[i$];
              if (n === version) {
                results$.push(i);
              }
            }
            return results$;
          }())[0];
          baseIndex = diff.baseIndex;
          c = diff.commentIndex;
          amendment = diff.content.map(billAmendment(diff, idx, c, baseIndex));
          return diff.diffnew = version, diff;
        };
        $scope.$watch('$state.params.otherBills', function(it){
          var otherBills, i$, len$, billId, results$ = [];
          otherBills = it != null ? it.split(',') : void 8;
          if (!(otherBills != null && otherBills.length)) {
            return;
          }
          $scope.bill_refs = [$scope.bill_ref].concat(otherBills);
          for (i$ = 0, len$ = otherBills.length; i$ < len$; ++i$) {
            billId = otherBills[i$];
            results$.push(LYModel.get("bills/" + billId).success(fn$));
          }
          return results$;
          function fn$(bill){
            return LYModel.get("bills/" + billId + "/data").success(function(data){
              $scope.toCompare == null && ($scope.toCompare = {});
              return $scope.toCompare[billId] = (bill.diff = diffmeta(data != null ? data.content : void 8), bill);
            });
          }
        });
        $scope.$watch('toCompare', function(it){
          var matrix, expand, k, val;
          if (!it) {
            return;
          }
          $scope.diffMatrix = matrix = {};
          expand = function(bill_ref, content){
            var i$, len$, d, lresult$, key$, j$, ref$, len1$, entry, x, ref1$, ref2$, results$ = [];
            for (i$ = 0, len$ = content.length; i$ < len$; ++i$) {
              d = content[i$];
              lresult$ = [];
              matrix[key$ = d.name] == null && (matrix[key$] = {});
              for (j$ = 0, len1$ = (ref$ = d.amendment).length; j$ < len1$; ++j$) {
                entry = ref$[j$];
                x = (ref2$ = (ref1$ = matrix[d.name])[key$ = entry.article || entry.originalArticle]) != null
                  ? ref2$
                  : ref1$[key$] = {};
                lresult$.push(x[bill_ref] = entry);
              }
              results$.push(lresult$);
            }
            return results$;
          };
          expand($scope.bill_ref, $scope.diff);
          for (k in it) {
            val = it[k];
            expand(k, val.diff);
          }
          return console.log(matrix);
        });
        return $scope.showSub = function(index){
          return angular.forEach($scope.steps, function(step, i){
            if (index === i && step.detail.length >= 1) {
              return step.sub = !step.sub;
            } else {
              return step.sub = false;
            }
          });
        };
      });
    });
  })
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
function curry$(f, bound){
  var context,
  _curry = function(args) {
    return f.length > 1 ? function(){
      var params = args ? args.concat() : [];
      context = bound ? context || this : this;
      return params.push.apply(params, arguments) <
          f.length && arguments.length ?
        _curry.call(context, params) : f.apply(context, params);
    } : f;
  };
  return _curry();
}
angular.module('app.controllers.calendar', []).controller({
  LYCalendar: ['$rootScope', '$scope', '$state', '$http', 'LYService', 'LYModel', '$sce'].concat(function($rootScope, $scope, $state, $http, LYService, LYModel, $sce){
    var today, committees, updatePage, updateDropdownOptions, parseState, insert, getSortedValue, isOnAir, getData;
    today = moment().startOf('day');
    committees = $rootScope.committees;
    $scope.type = 'sitting';
    $rootScope.activeTab = 'calendar';
    $scope.weeksOpts = buildWeeks(49);
    $scope.weeksOpts.unshift({
      start: moment(today).startOf('day').add('days', -1),
      end: moment(today).startOf('day').add('days', 1),
      label: '今日',
      name: 'today'
    });
    $scope.$watch('weeks', function(newV, oldV){
      if (!$scope.weeks) {
        return;
      }
      if (newV && oldV && !deepEq$(newV.label, oldV.label, '===')) {
        return $state.transitionTo('calendar.period', {
          period: $scope.weeks.name
        });
      }
    });
    $scope.change = function(type){
      $scope.type = type;
      updatePage();
    };
    $scope.$watch('$state.params.period', function(){
      if (!$state.params.period) {
        $state.transitionTo('calendar.period', {
          period: $scope.weeksOpts[0].name
        });
        return;
      }
      return updatePage();
    });
    function buildWeeks(first){
      var weeks, res$, i$, i;
      res$ = [];
      for (i$ = 0; i$ <= first; i$ += 7) {
        i = i$;
        res$.push(fn$());
      }
      weeks = res$;
      return weeks;
      function fn$(){
        var opt;
        opt = {
          start: moment(today).day(0 - i),
          end: moment(today).day(0 - i + 7)
        };
        opt.label = opt.start.format("YYYY:  MM-DD" + ' to ' + opt.end.format("MM-DD"));
        return opt.name = opt.start.format("YYYY-MM-DD" + '_' + opt.end.format("YYYY-MM-DD")), opt;
      }
    }
    updatePage = function(){
      var ref$, start, end, name, strS, strE;
      parseState($state.params.period);
      ref$ = /^calendar.period/.exec($state.current.name) ? parseState($state.params.period) : void 8, start = ref$[0], end = ref$[1], name = ref$[2];
      if (!start.isValid() || !end.isValid() || start > end) {
        ref$ = [$scope.weeksOpts[0].start, $scope.weeksOpts[0].end, 'today'], start = ref$[0], end = ref$[1], name = ref$[2];
      }
      ref$ = [start, end].map(function(it){
        return it.format('YYYY-MM-DD');
      }), strS = ref$[0], strE = ref$[1];
      name == null && (name = strS + "_" + strE);
      if (!deepEq$($state.current.name, name, '===')) {
        $state.transitionTo('calendar.period', {
          period: name
        });
      }
      getData($scope.type, strS, strE);
      return updateDropdownOptions(start, end);
    };
    updateDropdownOptions = function(start, end){
      var opt, first;
      first = (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = $scope.weeksOpts).length; i$ < len$; ++i$) {
          opt = ref$[i$];
          if (+opt.start === +start && +opt.end === +end) {
            results$.push(opt);
          }
        }
        return results$;
      }())[0];
      return $scope.weeks = first;
    };
    parseState = function(str){
      var r;
      if (/today/.exec(str) || !str) {
        return [$scope.weeksOpts[0].start, $scope.weeksOpts[0].end, $scope.weeksOpts[0].name];
      }
      r = str.split('_').map(function(s){
        return moment(s, 'YYYY-MM-DD');
      });
      r.push(str);
      return r;
    };
    insert = function(group, entry){
      var key;
      key = entry.date + entry.time_start + entry.time_end + entry.sitting_id;
      group[key] == null && (group[key] = entry);
      return group[key] = entry.id > group[key].id
        ? entry
        : group[key];
    };
    getSortedValue = function(obj){
      var keys, array, res$, i$, len$, k;
      keys = Object.keys(obj).sort();
      res$ = [];
      for (i$ = 0, len$ = keys.length; i$ < len$; ++i$) {
        k = keys[i$];
        if (obj[k]) {
          res$.push(obj[k]);
        }
      }
      array = res$;
      return array;
    };
    isOnAir = function(date, start, end){
      var d, ref$, s, e;
      d = moment(date).startOf('day');
      ref$ = [start, end].map(function(it){
        return moment(it, 'HH:mm:ss');
      }), s = ref$[0], e = ref$[1];
      return +today === +d && (s <= (ref$ = moment()) && ref$ <= e);
    };
    return getData = function(type, start, end){
      return LYModel.get('calendar', {
        params: {
          s: JSON.stringify({
            date: 1,
            time_start: 1
          }),
          q: JSON.stringify({
            date: {
              $gt: start,
              $lt: end
            },
            type: type
          }),
          l: 1000
        }
      }).success(function(arg$){
        var paging, entries, group, sorted, name;
        paging = arg$.paging, entries = arg$.entries;
        group = {};
        entries.map(function(it){
          var ref$, key$;
          it.formatDate = moment(it.date).zone('+00:00').format('MMM Do, YYYY');
          it.primaryCommittee = ((ref$ = it.committee) != null ? ref$[0] : void 8) || 'YS';
          it.onair = isOnAir(it.date, it.time_start, it.time_end);
          group[key$ = it.primaryCommittee] == null && (group[key$] = {});
          return insert(group[it.primaryCommittee], it);
        });
        sorted = {};
        for (name in group) {
          entries = group[name];
          sorted[name] = getSortedValue(group[name]);
        }
        $scope.group = sorted;
        return $scope.groupNum = Object.keys($scope.group).length;
      });
    };
  })
});
function deepEq$(x, y, type){
  var toString = {}.toString, hasOwnProperty = {}.hasOwnProperty,
      has = function (obj, key) { return hasOwnProperty.call(obj, key); };
  var first = true;
  return eq(x, y, []);
  function eq(a, b, stack) {
    var className, length, size, result, alength, blength, r, key, ref, sizeB;
    if (a == null || b == null) { return a === b; }
    if (a.__placeholder__ || b.__placeholder__) { return true; }
    if (a === b) { return a !== 0 || 1 / a == 1 / b; }
    className = toString.call(a);
    if (toString.call(b) != className) { return false; }
    switch (className) {
      case '[object String]': return a == String(b);
      case '[object Number]':
        return a != +a ? b != +b : (a == 0 ? 1 / a == 1 / b : a == +b);
      case '[object Date]':
      case '[object Boolean]':
        return +a == +b;
      case '[object RegExp]':
        return a.source == b.source &&
               a.global == b.global &&
               a.multiline == b.multiline &&
               a.ignoreCase == b.ignoreCase;
    }
    if (typeof a != 'object' || typeof b != 'object') { return false; }
    length = stack.length;
    while (length--) { if (stack[length] == a) { return true; } }
    stack.push(a);
    size = 0;
    result = true;
    if (className == '[object Array]') {
      alength = a.length;
      blength = b.length;
      if (first) { 
        switch (type) {
        case '===': result = alength === blength; break;
        case '<==': result = alength <= blength; break;
        case '<<=': result = alength < blength; break;
        }
        size = alength;
        first = false;
      } else {
        result = alength === blength;
        size = alength;
      }
      if (result) {
        while (size--) {
          if (!(result = size in a == size in b && eq(a[size], b[size], stack))){ break; }
        }
      }
    } else {
      if ('constructor' in a != 'constructor' in b || a.constructor != b.constructor) {
        return false;
      }
      for (key in a) {
        if (has(a, key)) {
          size++;
          if (!(result = has(b, key) && eq(a[key], b[key], stack))) { break; }
        }
      }
      if (result) {
        sizeB = 0;
        for (key in b) {
          if (has(b, key)) { ++sizeB; }
        }
        if (first) {
          if (type === '<<=') {
            result = size < sizeB;
          } else if (type === '<==') {
            result = size <= sizeB
          } else {
            result = size === sizeB;
          }
        } else {
          first = false;
          result = size === sizeB;
        }
      }
    }
    stack.pop();
    return result;
  }
}
angular.module('ly.g0v.tw.controllers', ['ng']).controller({
  LYDebates: ['$rootScope', '$scope', '$http', 'LYService', '$sce', 'LYModel'].concat(function($rootScope, $scope, $http, LYService, $sce, LYModel){
    var padLeft;
    $rootScope.activeTab = 'debates';
    $scope.answer = function(answer){
      switch (false) {
      case !answer:
        return $sce.trustAsHtml('已答');
      default:
        return $sce.trustAsHtml('未答');
      }
    };
    padLeft = function(str, length){
      if (str.length >= length) {
        return str;
      }
      return padLeft('0' + str, length);
    };
    $scope.source = function(arg$){
      var entity, source, link, str, href;
      entity = arg$.entity, source = entity.source;
      link = source[0].link;
      if (!link) {
        return '';
      }
      str = link[1].toString().concat(padLeft(link[2], 3)).concat(padLeft(link[3], 2));
      href = 'http://lis.ly.gov.tw/lgcgi/lypdftxt?' + str + ';'.concat(padLeft(link[4], 4)).concat(';' + padLeft(link[5], 4));
      return $sce.trustAsHtml("<a href=\"" + href + "\" target=\"_blank\">質詢公報</a>");
    };
    $scope.answers = function(arg$){
      var entity, answers, tmp;
      entity = arg$.entity, answers = entity.answers;
      tmp = '';
      angular.forEach(answers, function(value){
        var link, str, href;
        if (!value.source[0].text.match(/口頭答復/)) {
          link = value.source[0].link;
          str = link[1].toString().concat(padLeft(link[2], 3)).concat(padLeft(link[3], 2));
          href = 'http://lis.ly.gov.tw/lgcgi/lypdftxt?' + str + ';'.concat(padLeft(link[4], 4)).concat(';' + padLeft(link[5], 4));
          tmp += "<div><a href=\"" + href + "\" target=\"_blank\">書面答復</a></div>";
        }
      });
      if (deepEq$(tmp, '', '===')) {
        tmp += "口頭(見質詢公報)";
      }
      return $sce.trustAsHtml(tmp);
    };
    $scope.pagingOptions = {
      pageSizes: [10, 20, 30],
      pageSize: 30,
      currentPage: 1
    };
    $scope.$watch('pagingOptions', function(newVal, oldVal){
      if (!deepEq$(newVal.pageSize, oldVal.pageSize, '===') || !deepEq$(newVal.currentPage, oldVal.currentPage, '===')) {
        $scope.getData(newVal);
      }
    }, true);
    $scope.gridOptions = import$({
      showFilter: true,
      showColumnMenu: true,
      showGroupPanel: true,
      enableHighlighting: true,
      enableRowSelection: true,
      enablePaging: true,
      showFooter: true
    }, {
      rowHeight: 90,
      data: 'debates',
      pagingOptions: $scope.pagingOptions,
      i18n: 'zh-tw',
      columnDefs: [
        {
          field: 'tts_id',
          displayName: '系統號',
          width: 80
        }, {
          field: 'asked_by',
          displayName: '質詢人',
          width: 130,
          cellTemplate: "<div class=\"item\" legislator=\"asked_by\" ng-repeat=\"asked_by in row.entity.asked_by\"></div>"
        }, {
          field: 'source',
          displayName: '質詢公報',
          width: 80,
          cellTemplate: "<div ng-bind-html=\"source(row)\"></div>"
        }, {
          field: 'answers',
          displayName: '答復公報',
          width: 100,
          cellTemplate: "<div ng-bind-html=\"answers(row)\"></div>"
        }, {
          field: 'summary',
          displayName: '案由',
          visible: false
        }, {
          field: 'answered',
          displayName: '答復',
          width: '50',
          cellTemplate: "<div ng-bind-html=\"answer(row)\"></div>"
        }, {
          field: 'date_asked',
          cellFilter: 'date: mediumDate',
          width: '100',
          displayName: '質詢日期'
        }, {
          field: 'category',
          width: '*',
          displayName: '類別',
          cellTemplate: "<div ng-repeat=\"c in row.getProperty(col.field) track by $id($index)\"><span class=\"label\">{{c}}</span></div>"
        }, {
          field: 'topic',
          displayName: '主題',
          width: '*',
          cellTemplate: "<div ng-repeat=\"c in row.getProperty(col.field) track by $id($index)\"><span class=\"label\">{{c}}</span></div>"
        }, {
          field: 'keywords',
          displayName: '關鍵詞',
          width: '*',
          cellTemplate: "<div ng-repeat=\"c in row.getProperty(col.field) track by $id($index)\"><span class=\"label\">{{c}}</span></div>"
        }, {
          field: 'answered_by',
          displayName: '答復人',
          width: '80',
          cellTemplate: "<div ng-repeat=\"c in row.getProperty(col.field) track by $id($index)\"><span >{{c}}</span></div>"
        }, {
          field: 'interpellation_type',
          displayName: '質詢性質',
          width: '*'
        }
      ]
    });
    $scope.getData = function(arg$){
      var currentPage, pageSize;
      currentPage = arg$.currentPage, pageSize = arg$.pageSize;
      return LYModel.get('ttsinterpellation', {
        params: {
          sk: (currentPage - 1) * pageSize,
          l: pageSize
        }
      }).success(function(arg$){
        var paging, entries;
        paging = arg$.paging, entries = arg$.entries;
        angular.forEach(entries, function(value, key){
          value.date_asked = new Date(value.date_asked);
          value.source = value.source;
        });
        return $scope.debates = entries;
      });
    };
    return $scope.getData($scope.pagingOptions);
  })
});
function deepEq$(x, y, type){
  var toString = {}.toString, hasOwnProperty = {}.hasOwnProperty,
      has = function (obj, key) { return hasOwnProperty.call(obj, key); };
  var first = true;
  return eq(x, y, []);
  function eq(a, b, stack) {
    var className, length, size, result, alength, blength, r, key, ref, sizeB;
    if (a == null || b == null) { return a === b; }
    if (a.__placeholder__ || b.__placeholder__) { return true; }
    if (a === b) { return a !== 0 || 1 / a == 1 / b; }
    className = toString.call(a);
    if (toString.call(b) != className) { return false; }
    switch (className) {
      case '[object String]': return a == String(b);
      case '[object Number]':
        return a != +a ? b != +b : (a == 0 ? 1 / a == 1 / b : a == +b);
      case '[object Date]':
      case '[object Boolean]':
        return +a == +b;
      case '[object RegExp]':
        return a.source == b.source &&
               a.global == b.global &&
               a.multiline == b.multiline &&
               a.ignoreCase == b.ignoreCase;
    }
    if (typeof a != 'object' || typeof b != 'object') { return false; }
    length = stack.length;
    while (length--) { if (stack[length] == a) { return true; } }
    stack.push(a);
    size = 0;
    result = true;
    if (className == '[object Array]') {
      alength = a.length;
      blength = b.length;
      if (first) { 
        switch (type) {
        case '===': result = alength === blength; break;
        case '<==': result = alength <= blength; break;
        case '<<=': result = alength < blength; break;
        }
        size = alength;
        first = false;
      } else {
        result = alength === blength;
        size = alength;
      }
      if (result) {
        while (size--) {
          if (!(result = size in a == size in b && eq(a[size], b[size], stack))){ break; }
        }
      }
    } else {
      if ('constructor' in a != 'constructor' in b || a.constructor != b.constructor) {
        return false;
      }
      for (key in a) {
        if (has(a, key)) {
          size++;
          if (!(result = has(b, key) && eq(a[key], b[key], stack))) { break; }
        }
      }
      if (result) {
        sizeB = 0;
        for (key in b) {
          if (has(b, key)) { ++sizeB; }
        }
        if (first) {
          if (type === '<<=') {
            result = size < sizeB;
          } else if (type === '<==') {
            result = size <= sizeB
          } else {
            result = size === sizeB;
          }
        } else {
          first = false;
          result = size === sizeB;
        }
      }
    }
    stack.pop();
    return result;
  }
}
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
var replace$ = ''.replace;
function trim(str){
  return replace$.call(str, /^s+/mg, '').replace(/^\s+|\s+$/g, '');
}
angular.module('ly.diff', []).directive('lyDiff', ['$parse', '$sce'].concat(function($parse, $sce){
  return {
    restrict: 'A',
    scope: {
      options: '=lyDiff'
    },
    transclude: true,
    templateUrl: 'app/diff/diff.html',
    controller: ['$transclude', '$element', '$attrs', '$scope'].concat(function($transclude, $element, $attrs, $scope){
      var ref$;
      $scope.$watchCollection(['left', 'right'], function(){
        var ref$;
        if (!($scope.left || $scope.right)) {
          return;
        }
        $scope.leftItem = $scope.heading;
        $scope.leftItemAnchor = $scope.anchor;
        $scope.rightItem = (ref$ = $scope.headingRight) != null
          ? ref$
          : $scope.leftItem;
        $scope.rightItemAnchor = (ref$ = $scope.anchorRight) != null
          ? ref$
          : $scope.leftItemAnchor;
        $scope.baseless = !$scope.left;
        return $scope.difflines = lineBasedDiff($scope.left, $scope.right).map(function(it){
          var ref$;
          it.left = $sce.trustAsHtml(it.left || '無');
          it.right = $sce.trustAsHtml(it.right);
          it.leftdesc = it.state === 'equal' ? '相同' : '現行';
          it.leftstate = it.state === 'equal' ? '' : 'red';
          it.rightstate = (ref$ = it.state) === 'replace' || ref$ === 'empty' || ref$ === 'insert' || ref$ === 'delete' ? 'green' : '';
          it.rightdesc = (function(){
            var ref$;
            switch (ref$ = [it.state], false) {
            case 'replace' !== ref$[0]:
              return '修正';
            case 'delete' !== ref$[0]:
              return '刪除';
            case 'insert' !== ref$[0]:
              return '新增';
            default:
              return '相同';
            }
          }());
          return it;
        });
      });
      if ($scope.options.parse) {
        $transclude(function(clone){
          var comment;
          comment = clone.closest('.comment').text();
          return $scope.comment = $sce.trustAsHtml(comment), $scope.heading = clone.closest('.heading').text(), $scope.anchor = clone.closest('.anchor').text(), $scope.left = trim(clone.closest('.left').text()), $scope.right = trim(clone.closest('.right').text()), $scope;
        });
      } else {
        ($scope.left = (ref$ = $scope.options).left, $scope.right = ref$.right, $scope.heading = ref$.heading, $scope.headingRight = ref$.headingRight, $scope.anchor = ref$.anchor, $scope.anchorRight = ref$.anchorRight, $scope).comment = $sce.trustAsHtml($scope.options.comment);
      }
      if ((ref$ = $scope.heading) != null && ref$.match(/^(\d*?)(-(\d*?))?$/)) {
        $scope.heading = '§' + $scope.heading;
      }
      if ((ref$ = $scope.headingRight) != null && ref$.match(/^(\d*?)(-(\d*?))?$/)) {
        return $scope.headingRight = '§' + $scope.headingRight;
      }
    })
  };
}));
var maketree;
maketree = function(el, root, outerHeight){
  var margin, width, height, tree, svg, g, nodes, x, link, node;
  margin = {
    top: 0,
    right: 40,
    bottom: 0,
    left: 40
  };
  width = 960 - margin.right;
  height = outerHeight - margin.top - margin.bottom;
  tree = d3.layout.tree().size([height, 1]).separation(function(){
    return 1;
  });
  tree.sort(function(a, b){
    return +a.name - +b.name;
  });
  svg = d3.select(el).append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).style("margin", "1em 0 1em " + -margin.left + "px");
  g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
  nodes = tree.nodes(root);
  x = d3.scale.linear().range([0, width]);
  x.domain([
    d3.min(nodes, function(it){
      return +it.name;
    }), d3.max(nodes, function(it){
      return +it.name;
    })
  ]);
  link = g.selectAll(".link").data(tree.links(nodes)).enter().append("path").attr("class", "link").attr("d", d3.svg.diagonal().source(function(d){
    return {
      y: x(+d.source.name),
      x: d.source.x
    };
  }).target(function(d){
    return {
      y: x(+d.target.name),
      x: d.target.x
    };
  }).projection(function(d){
    return [d.y, d.x];
  }));
  node = g.selectAll(".node").data(nodes).enter().append("g").attr("class", function(d){
    return (d.type || "") + " node";
  }).attr("transform", function(it){
    return "translate(" + x(+it.name) + "," + it.x + ")";
  });
  node.append("text").attr("x", 6).attr("dy", ".32em").text(function(it){
    return it.name;
  }).each(function(d){
    return d.width = this.getComputedTextLength() + 12;
  });
  node.insert("rect", "text").attr("ry", 6).attr("rx", 6).attr("y", -10).attr("height", 20).attr("width", function(d){
    return Math.max(32, d.width);
  });
  return svg;
};
window.billHistory = function(data, $scope){
  var margin, width, height, x, y, meetings, min, max, xAxis, createTree, root;
  margin = {
    top: 20,
    right: 20,
    bottom: 100,
    left: 40
  };
  width = 960 - margin.left - margin.right;
  height = 500 - margin.top - margin.bottom;
  x = d3.scale.ordinal().rangeRoundBands([0, width], 0.1);
  y = d3.scale.linear().rangeRound([height, 0]);
  meetings = data.map(function(it){
    return it.motions.map(function(it){
      return it.meeting;
    });
  }).reduce(curry$(function(x$, y$){
    return x$.concat(y$);
  }));
  min = d3.min(meetings);
  max = d3.max(meetings);
  x.domain(data.map(function(it){
    return it.motions.map(function(it){
      return it.meeting;
    });
  }).reduce(curry$(function(x$, y$){
    return x$.concat(y$);
  })));
  xAxis = d3.svg.axis().scale(x).orient('bottom');
  createTree = function(node, data, id){
    var b, bill, leaf, i$, ref$, len$, m, mnode, ref1$, r, rnode, results$ = [];
    bill = (function(){
      var i$, ref$, len$, results$ = [];
      for (i$ = 0, len$ = (ref$ = data).length; i$ < len$; ++i$) {
        b = ref$[i$];
        if (b.id === id) {
          results$.push(b);
        }
      }
      return results$;
    }())[0];
    if (bill == null) {
      return;
    }
    leaf = node;
    for (i$ = 0, len$ = (ref$ = bill.motions).length; i$ < len$; ++i$) {
      m = ref$[i$];
      mnode = {
        name: m.meeting,
        bill: bill,
        'class': 'motion',
        children: [],
        type: "text"
      };
      console.log('push', leaf, mnode);
      leaf.children.push(mnode);
      leaf = mnode;
    }
    for (i$ = 0, len$ = (ref$ = (ref1$ = bill.related) != null
      ? ref1$
      : []).length; i$ < len$; ++i$) {
      r = ref$[i$];
      results$.push(rnode = createTree(leaf, data, r));
    }
    return results$;
  };
  root = {
    name: 17,
    'class': 'root',
    children: []
  };
  createTree(root, data, data[0].id);
  createTree(root, data, data[0].id);
  console.log(root);
  return maketree('.history', root, 360);
};
function curry$(f, bound){
  var context,
  _curry = function(args) {
    return f.length > 1 ? function(){
      var params = args ? args.concat() : [];
      context = bound ? context || this : this;
      return params.push.apply(params, arguments) <
          f.length && arguments.length ?
        _curry.call(context, params) : f.apply(context, params);
    } : f;
  };
  return _curry();
}
var stackedBars;
window.loadMotions = function($scope){
  return $(function(){
    return d3.json('/data/8-2.json', function(motions){
      var data;
      data = motions.map(function(arg$){
        var meeting, announcement, discussion, by_status, exmotion, res$, i$, len$, d, ann_status, dis_status, exm_status;
        meeting = arg$.meeting, announcement = arg$.announcement, discussion = arg$.discussion;
        by_status = function(){
          return d3.nest().key(function(it){
            var ref$;
            return (ref$ = it.status) != null ? ref$ : 'unknown';
          }).rollup(function(it){
            return it.length;
          });
        };
        res$ = [];
        for (i$ = 0, len$ = discussion.length; i$ < len$; ++i$) {
          d = discussion[i$];
          if (d.type === 'exmotion') {
            res$.push(d);
          }
        }
        exmotion = res$;
        res$ = [];
        for (i$ = 0, len$ = discussion.length; i$ < len$; ++i$) {
          d = discussion[i$];
          if (d.type !== 'exmotion') {
            res$.push(d);
          }
        }
        discussion = res$;
        ann_status = by_status().map(announcement);
        dis_status = by_status().map(discussion);
        exm_status = by_status().map(exmotion);
        return {
          sitting: meeting.sitting,
          ann: announcement.length,
          dis: discussion != null ? discussion.length : void 8,
          ann_status: ann_status,
          dis_status: dis_status,
          exm_status: exm_status,
          announcement: announcement,
          discussion: discussion,
          exmotion: exmotion,
          meeting: meeting
        };
      });
      $scope.$root.$broadcast('data', data);
      return stackedBars(data, $scope);
    });
  });
};
stackedBars = function(data, $scope){
  var margin, width, height, x, y, color, xAxis, yAxis, totalW, totalH, vb, svg, legendW, legendH, legends, ann_color, show, state, desc, cur_desc, legend;
  margin = {
    top: 10,
    right: 20,
    bottom: 10,
    left: 60
  };
  width = 1600;
  height = 600;
  x = d3.scale.ordinal().rangeRoundBands([0, width], 0.1);
  y = d3.scale.linear().rangeRound([height, 0]);
  color = d3.scale.ordinal().range(['#98abc5', '#8a89a6', '#7b6888', '#6b486b', '#a05d56', '#d0743c', '#ff8c00']);
  xAxis = d3.svg.axis().scale(x).orient('bottom');
  yAxis = d3.svg.axis().scale(y).orient('left').tickFormat(d3.format('.2s'));
  totalW = width + margin.left + margin.right;
  totalH = height + margin.top + margin.bottom;
  vb = "0 0 " + totalW + " " + totalH;
  svg = d3.select(".chart").append("svg").attr("width", "100%").attr("height", "80%").attr("viewBox", vb).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
  legendW = 200;
  legendH = 800;
  legends = d3.select(".legends").append('svg').attr("width", "100%").attr("height", "80%").attr('viewbox', '0 0 ' + legendW + ' ' + legendH);
  ann_color = d3.scale.ordinal().range(['#cccccc', '#8a89a6', '#7b6888', '#6b486b', '#ff8c00', '#ff1c00', '#000000', '#23ff8c', '#6b486b', '#dddddd', '#dddddd']).domain(['retrected', 'rejected', 'accepted', 'committee', 'prioritized', 'unhandled', 'consultation', 'passed', 'ey', 'other', 'unknown']);
  color.domain(['ann', 'dis']);
  data.forEach(function(d){
    var y0, ref$;
    y0 = 0;
    d.cum = color.domain().map(function(name){
      return {
        name: name,
        y0: y0,
        y1: y0 += +d[name]
      };
    });
    y0 = 0;
    d.ann_cum = ann_color.domain().map(function(name){
      var ref$;
      return {
        name: name,
        y0: y0,
        y1: y0 += +((ref$ = d.ann_status[name]) != null ? ref$ : 0)
      };
    });
    y0 = 0;
    d.dis_cum = ann_color.domain().map(function(name){
      var ref$;
      return {
        name: name,
        y0: y0,
        y1: y0 += +((ref$ = d.dis_status[name]) != null ? ref$ : 0)
      };
    });
    y0 = 0;
    d.exm_cum = ann_color.domain().map(function(name){
      var ref$;
      return {
        name: name,
        y0: y0,
        y1: y0 += +((ref$ = d.exm_status[name]) != null ? ref$ : 0)
      };
    });
    return d.total = (ref$ = d.cum)[ref$.length - 1].y1;
  });
  x.domain(data.map(function(it){
    return it.sitting;
  }));
  y.domain([
    0, d3.max(data, function(it){
      return it.total;
    })
  ]);
  show = function(type, name, i){
    return $scope.$root.$broadcast('show', i, type, name);
  };
  svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis);
  state = svg.selectAll(".sitting").data(data).enter().append("g").attr("class", "g").attr("transform", function(it){
    return "translate(" + x(it.sitting) + ",0)";
  }).on('click', function(d){
    return show('announcement', d.name, cur_desc);
  });
  desc = svg.append("g").selectAll('.desc').data(['報告事項', '討論事項', '臨時提案']).enter().append("text").attr('class', 'desc').attr('transform', function(it, i){
    return "rotate(-90)translate(" + (-height - 10) + "," + (x.rangeBand() * i / 3 + x(5)) + ")";
  }).attr("dy", ".71em").style("text-anchor", "end").text(function(it){
    return it;
  });
  cur_desc = null;
  state.selectAll("rect.sep").data(function(it){
    return [it.sitting];
  }).enter().append('rect').attr('class', 'sep').attr('width', 1).attr('y', 0).attr('x', x.rangeBand() + 3).attr('height', height).style('fill', 'none').style('stroke', 'black').style('stroke-width', 1).style('opacity', 0.2);
  state.selectAll("rect.col").data(function(it){
    return [it.sitting];
  }).enter().append('rect').attr('class', 'col').attr('width', x.rangeBand()).attr('y', 0).attr('height', height).style('fill', 'white').style('opacity', 0).on('mouseover', function(cur){
    if (cur === cur_desc) {
      return;
    }
    desc.attr('transform', function(it, i){
      return "rotate(-90)translate(" + (-height - 20) + "," + (x.rangeBand() * i / 3 + x(cur)) + ")";
    });
    return cur_desc = cur;
  });
  state.selectAll("rect.ann").data(function(it){
    return it.ann_cum;
  }).enter().append("rect").attr('class', 'ann').attr("width", x.rangeBand() / 3 - 2).attr("y", function(it){
    return y(it.y1);
  }).attr("height", function(d){
    return y(d.y0) - y(d.y1);
  }).style("fill", function(d){
    return ann_color(d.name);
  });
  state.selectAll("rect.dis").data(function(it){
    return it.dis_cum;
  }).enter().append("rect").attr('class', 'dis').attr("width", x.rangeBand() / 3 - 2).attr("x", function(){
    return x.rangeBand() / 3 + 1;
  }).attr("y", function(it){
    return y(it.y1);
  }).attr("height", function(d){
    return y(d.y0) - y(d.y1);
  }).style("fill", function(d){
    return ann_color(d.name);
  });
  state.selectAll("rect.exm").data(function(it){
    return it.exm_cum;
  }).enter().append("rect").attr('class', 'exm').attr("width", x.rangeBand() / 3 - 2).attr("x", function(){
    return x.rangeBand() / 3 * 2 + 1;
  }).attr("y", function(it){
    return y(it.y1);
  }).attr("height", function(d){
    return y(d.y0) - y(d.y1);
  }).style("fill", function(d){
    return ann_color(d.name);
  });
  legend = legends.selectAll(".legend").data(ann_color.domain().slice().reverse()).enter().append('g').attr("class", "legend").attr("transform", function(d, i){
    return "translate(0," + i * 20 + ")";
  });
  legend.append("rect").attr("x", 0).attr("width", 18).attr("height", 18).style("fill", ann_color);
  legend.append("text").attr("x", 20).attr("y", 9).attr("dy", ".35em").text(function(it){
    return $scope.statusName(it);
  });
  return svg.append("g").attr("class", "y axis").call(yAxis).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", ".71em").style("text-anchor", "end").text("議案數");
};
angular.module('utils', []).controller('topBtnCtrl', ['$scope', '$window'].concat(function($scope, $window){
  $scope.showBtn = false;
  angular.element($window).bind('scroll', function(){
    console.log(window.pageYOffset);
    if (window.pageYOffset > 500) {
      $scope.showBtn = true;
    } else {
      $scope.showBtn = false;
    }
    return $scope.$apply();
  });
  return $scope.jumpToTop = function(){
    return window.scrollTo(0, 0);
  };
}));
angular.module('app.controllers.search', []).controller({
  LYSearch: ['$rootScope', '$scope', '$state', '$timeout', 'LYModel'].concat(function($rootScope, $scope, $state, $timeout, LYModel){
    var doSearch;
    $scope.limit = 12;
    $scope.sk = 0;
    $scope.results = [];
    $scope.$watch('$state.params.keyword', function(){
      $scope.sk = 0;
      $scope.keyword = $state.params.keyword;
      if (!$state.params.keyword) {
        return;
      }
      return LYModel.get('laws', {
        params: {
          q: JSON.stringify({
            name: {
              $matches: $state.params.keyword
            }
          }),
          f: JSON.stringify({
            id: 1
          }),
          fo: true
        }
      }).success(function(arg$){
        var id;
        id = arg$.id;
        $scope.lawId = id;
        $scope.results = [];
        return $scope.moreResults();
      });
    });
    $scope.moreResults = function(){
      $scope.busy = true;
      return doSearch($scope.lawId, function(res){
        var i$, len$, obj;
        for (i$ = 0, len$ = res.length; i$ < len$; ++i$) {
          obj = res[i$];
          LYModel.get("bills/" + obj.bill_ref).success(fn$);
        }
        if (res.length === 0) {
          $scope.stopDetect = true;
        }
        return $scope.busy = false;
        function fn$(data){
          return $scope.results.push(data);
        }
      });
    };
    return doSearch = function(lawId, cb){
      return LYModel.get('amendments', {
        params: {
          q: JSON.stringify({
            law_id: lawId
          }),
          f: JSON.stringify({
            bill_ref: 1
          }),
          l: $scope.limit,
          sk: $scope.sk
        }
      }).success(function(arg$){
        var paging, entries;
        paging = arg$.paging, entries = arg$.entries;
        $scope.sk += $scope.limit;
        return cb(entries);
      });
    };
  })
});
var names_to_avatars, keys, uniq, split$ = ''.split, join$ = [].join;
names_to_avatars = function(names){
  var i$, len$, name, results$ = [];
  for (i$ = 0, len$ = names.length; i$ < len$; ++i$) {
    name = names[i$];
    results$.push(CryptoJS.MD5("MLY/" + name).toString());
  }
  return results$;
};
keys = function(obj){
  var key, val, results$ = [];
  for (key in obj) {
    val = obj[key];
    results$.push(key);
  }
  return results$;
};
uniq = function(list){
  var elem;
  return keys((function(){
    var i$, ref$, len$, results$ = {};
    for (i$ = 0, len$ = (ref$ = list).length; i$ < len$; ++i$) {
      elem = ref$[i$];
      results$[elem] = 1;
    }
    return results$;
  }()));
};
angular.module('app.controllers.sittings-new', []).controller({
  LYSittingsNew: ['$scope', '$rootScope', '$state', '$timeout', 'LYService', 'LYModel', '$sce', '$anchorScroll'].concat(function($scope, $rootScope, $state, $timeout, LYService, LYModel, $sce, $anchorScroll){
    $scope.adv_mode = false;
    return $scope.$watch('$state.params.sittingId', function(){
      return LYModel.get("sittings/" + $state.params.sittingId + "/motions").success(function(motions){
        var motion_map, i$, len$, index, bill_id, ref$, sitting_introduced, dummy, results$ = [];
        motion_map = {};
        for (i$ = 0, len$ = motions.length; i$ < len$; ++i$) {
          index = i$;
          bill_id = motions[i$].bill_id;
          motion_map[bill_id] = index;
        }
        $scope.motions = motions;
        for (i$ = 0, len$ = motions.length; i$ < len$; ++i$) {
          ref$ = motions[i$], bill_id = ref$.bill_id, sitting_introduced = ref$.sitting_introduced;
          if (!sitting_introduced) {
            results$.push(dummy = null);
          } else {
            results$.push(LYModel.get("bills/" + bill_id).success(fn$));
          }
        }
        return results$;
        function fn$(arg$){
          var motions, sponsors, cosponsors, bill_id, res$, i$, len$, m, committee_names, ref$, c, dates, d, date_display;
          motions = arg$.motions, sponsors = arg$.sponsors, cosponsors = arg$.cosponsors, bill_id = arg$.bill_id;
          sponsors || (sponsors = []);
          cosponsors || (cosponsors = []);
          res$ = [];
          for (i$ = 0, len$ = motions.length; i$ < len$; ++i$) {
            m = motions[i$];
            if (m.sitting_id === $state.params.sittingId) {
              res$.push(m);
            }
          }
          motions = res$;
          if (motions.length === 1) {
            committee_names = [];
            if ((ref$ = motions[0].committee) != null && ref$.length) {
              for (i$ = 0, len$ = (ref$ = motions[0].committee).length; i$ < len$; ++i$) {
                c = ref$[i$];
                committee_names.push($rootScope.committees[c] + '委員會');
              }
            }
            committee_names || (committee_names = ['院會']);
            dates = uniq((function(){
              var i$, ref$, len$, results$ = [];
              for (i$ = 0, len$ = (ref$ = motions[0].dates).length; i$ < len$; ++i$) {
                d = ref$[i$];
                results$.push(d.date);
              }
              return results$;
            }()));
            dates.sort();
            d = new Date(split$.call(dates[dates.length - 1], '-'));
            date_display = d.getMonth() + '/' + d.getDate();
          } else {
            console.warning('Unexpected motions.length', motions);
            committee_names = [];
          }
          return ref$ = $scope.motions[motion_map[bill_id]], ref$.category = '修法', ref$.bill_id = bill_id, ref$.date = date_display, ref$.sponsors = sponsors || [], ref$.cosponsors = cosponsors || [], ref$.show = true, ref$.committees = join$.call(committee_names, ','), ref$.sponsor_avatars = names_to_avatars(sponsors), ref$.cosponsor_avatars = names_to_avatars(cosponsors), ref$;
        }
      });
    });
  })
});
var replace$ = ''.replace;
function getVideosByCut(LYModel, sitting, cb){
  return LYModel.get("sittings/" + sitting + "/videos").success(function(videos){
    var whole, res$, i$, len$, v, ref$, clips, cut, start, end, speakers, j$, len1$, clip;
    res$ = [];
    for (i$ = 0, len$ = videos.length; i$ < len$; ++i$) {
      v = videos[i$];
      if (v.firm === 'whole') {
        res$.push((v.first_frame = moment((ref$ = v.first_frame_timestamp) != null
          ? ref$
          : v.time), v));
      }
    }
    whole = res$;
    res$ = [];
    for (i$ = 0, len$ = videos.length; i$ < len$; ++i$) {
      v = videos[i$];
      if (v.firm !== 'whole') {
        res$.push({
          time: v.time,
          mly: replace$.call(v.speaker, /\s*委員/, ''),
          length: v.length,
          thumb: v.thumb
        });
      }
    }
    clips = res$;
    for (i$ = 0, len$ = whole.length; i$ < len$; ++i$) {
      cut = whole[i$];
      start = cut.first_frame;
      end = start + cut.length * 1000;
      speakers = clips.filter(fn$);
      for (j$ = 0, len1$ = speakers.length; j$ < len1$; ++j$) {
        clip = speakers[j$];
        clip.offset = moment(clip.time) - start;
      }
      cut.speakers = speakers;
    }
    return cb(whole);
    function fn$(it){
      var ref$;
      return +start < (ref$ = +moment(it.time)) && ref$ <= end;
    }
  });
}
angular.module('app.controllers.sittings', []).controller({
  LYSittings: ['$rootScope', '$scope', '$http', '$state', 'LYService', 'LYModel', '$location'].concat(function($rootScope, $scope, $http, $state, LYService, LYModel, $location){
    var committees, loadList, loadSitting, getMotionsInType, hashWatch;
    $rootScope.activeTab = 'sittings';
    committees = $rootScope.committees;
    $scope.lists = {};
    if (window.YT) {
      $scope.youtubeReady = true;
    } else {
      $scope.$on('youtube-ready', function(){
        return $scope.youtubeReady = true;
      });
    }
    $scope.setContext = function(ctx){
      $scope.context = ctx;
      return $state.params.sitting = null;
    };
    $scope.$watch('$state.params.sitting', function(){
      var that;
      if (that = $state.params.sitting) {
        $scope.sitting_id = that;
        console.log('specified sitting, get context from id of sitting');
        $scope.context = replace$.call(that, /[\d-]/g, '');
        return loadSitting(that);
      } else {
        console.log('no specified sitting, use YS as default context if necessary');
        return $scope.context || ($scope.context = 'YS');
      }
    });
    $scope.$watch('context', function(newV, oldV){
      if (!(newV || oldV)) {
        return;
      }
      console.log('current context is ', $scope.context);
      if ($scope.lists.hasOwnProperty($scope.context)) {
        return $scope.currentList = $scope.lists[$scope.context];
      } else {
        console.log('using context that we do not have yet. fetch it ');
        return loadList();
      }
    });
    $scope.$watchCollection('[absolutePlayerTime, shareOffset, dateOffset, timeOffset]', function(){
      var hash;
      hash = $scope.shareOffset ? ($scope.dateOffset = $scope.absolutePlayerTime.format('YYYY-MM-DD'), $scope.timeOffset = $scope.absolutePlayerTime.format('HH:mm:ss'), '#' + $scope.dateOffset + 'T' + $scope.timeOffset) : '';
      $scope.sharelink = replace$.call($location.absUrl(), /#.*$/, '') + hash;
      return $scope.sharelinkEscaped = replace$.call($location.absUrl(), /#.*$/, '') + escape(hash);
    });
    loadList = function(length){
      var type;
      if (committees[$scope.context]) {
        type = "{\"" + $scope.context + "\"}";
      } else {
        type = null;
      }
      if (!length) {
        length = 40;
      }
      $scope.loadingList = true;
      return LYModel.get('sittings', {
        params: {
          q: {
            ad: 8,
            committee: type
          },
          l: length,
          f: {
            motions: false,
            videos: false
          }
        }
      }).success(function(arg$){
        var entries;
        entries = arg$.entries;
        $scope.loadingList = false;
        $scope.lists[$scope.context] = entries;
        return $scope.currentList = $scope.lists[$scope.context].sort(function(x, y){
          if (x.id > y.id) {
            return -1;
          } else {
            return 1;
          }
        });
      });
    };
    $scope.$watch('currentList', function(newV, oldV){
      var matched, ref$, s, id, specified;
      if (!$scope.currentList) {
        return;
      }
      matched = (ref$ = (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = $scope.currentList).length; i$ < len$; ++i$) {
          s = ref$[i$], id = s.id;
          if (id === $state.params.sitting) {
            results$.push(s);
          }
        }
        return results$;
      }())) != null ? ref$[0] : void 8;
      if (matched) {
        return $scope.chosenSitting = matched;
      } else {
        specified = $state.params.sitting;
        if (specified) {
          console.log('user specified a id out of fetched list, use the i and keep drop-down list blank');
          return loadSitting(specified);
        } else {
          console.log('user move to a new context, use the lastest sitting by default');
          return $scope.chosenSitting = $scope.currentList[0];
        }
      }
    });
    $scope.$watch('chosenSitting', function(newV, oldV){
      var id;
      if (!newV) {
        return;
      }
      id = $scope.chosenSitting.id;
      return loadSitting($scope.chosenSitting.id);
    });
    loadSitting = function(id){
      var state;
      state = /^sittings.detail/.exec($state.current.name) ? $state.current.name : 'sittings.detail';
      $state.transitionTo(state, {
        sitting: id
      });
      $scope.loadingSitting = true;
      return LYModel.get("sittings/" + id).success(function(result){
        $scope.loadingSitting = false;
        import$($scope, result);
        $scope.data = [];
        $scope.data['announcement'] = getMotionsInType(result.motions, 'announcement');
        $scope.data['discussion'] = getMotionsInType(result.motions, 'discussion');
        $scope.data['exmotion'] = getMotionsInType(result.motions, 'exmotion');
        $scope.setType('announcement');
        return LYModel.get("sittings/" + id + "/videos").success(function(videos){
          return $scope.videos = videos;
        });
      });
    };
    getMotionsInType = function(motions, type){
      var m;
      return (function(){
        var i$, ref$, len$, results$ = [];
        for (i$ = 0, len$ = (ref$ = motions).length; i$ < len$; ++i$) {
          m = ref$[i$];
          if (m.motion_class === type) {
            results$.push(m);
          }
        }
        return results$;
      }());
    };
    import$($scope, {
      allTypes: [
        {
          key: 'announcement',
          value: '報告事項'
        }, {
          key: 'discussion',
          value: '討論事項'
        }, {
          key: 'exmotion',
          value: '臨時提案'
        }
      ],
      setType: function(type){
        var entries, allStatus, a, e, i$, len$, ref$, that, party;
        entries = $scope.data[type];
        allStatus = [{
          key: 'all',
          value: '全部'
        }].concat((function(){
          var results$ = [];
          for (a in (fn$())) {
            results$.push({
              key: a,
              value: $scope.statusName(a)
            });
          }
          return results$;
          function fn$(){
            var i$, ref$, len$, ref1$, results$ = {};
            for (i$ = 0, len$ = (ref$ = entries).length; i$ < len$; ++i$) {
              e = ref$[i$];
              results$[(ref1$ = e.status) != null ? ref1$ : 'unknown'] = true;
            }
            return results$;
          }
        }()));
        if (!in$($scope.status, allStatus.map(function(it){
          return it.key;
        }))) {
          $scope.status = '';
        }
        for (i$ = 0, len$ = entries.length; i$ < len$; ++i$) {
          e = entries[i$];
          if (e.avatars == null) {
            switch (ref$ = [e.proposed_by], false) {
            case !(that = /委員(.*?)(、|等)/.exec(ref$[0])):
              e.avatars = [that[1]];
              break;
            case !(that = /本院(.*黨團)/.exec(ref$[0])):
              party = LYService.parseParty(replace$.call(that[1], /黨團$/, ''));
              e.avatars = [{
                party: party,
                name: that[1],
                iconClass: party
              }];
            }
          }
        }
        return $scope.type = type, $scope.entries = entries, $scope.allStatus = allStatus, $scope;
      },
      setStatus: function(s){
        if (s === 'all') {
          s = '';
        }
        if (s === 'unknown') {
          s = '';
        }
        return $scope.status = s;
      },
      statusName: function(s){
        var names, ref$;
        names = {
          unknown: '未知',
          other: '其他',
          passed: '通過',
          consultation: '協商',
          retrected: '撤回',
          unhandled: '未處理',
          ey: '請行政院研處',
          prioritized: '逕付二讀',
          committee: '交委員會',
          rejected: '退回',
          accepted: '查照'
        };
        return (ref$ = names[s]) != null ? ref$ : s;
      }
    });
    $scope.playFrom = function(seconds){
      if ($scope.player.getPlayerState() === -1) {
        $scope.player.playVideo();
        return $scope.player.nextStart = seconds;
      } else {
        return $scope.player.seekTo(seconds);
      }
    };
    return $scope.$watch('$state.current.name + $state.params.sitting', function(){
      var playTime;
      if ($state.current.name === 'sittings.detail.video') {
        $scope.video = true;
        if ($scope.loaded === $state.params.sitting) {
          return;
        }
        $scope.loaded = $state.params.sitting;
        hashWatch = $scope.$watch('$location.hash()', function(it){
          if (!it) {
            return;
          }
          return playTime = moment(it + '+08:00');
        });
        return getVideosByCut(LYModel, $state.params.sitting, function(cuts){
          var i$, len$, v, done, onPlayerReady, timerId, onPlayerStateChange, playerInit, mkwave;
          if (playTime) {
            for (i$ = 0, len$ = cuts.length; i$ < len$; ++i$) {
              v = cuts[i$];
              if (v.first_frame <= playTime && playTime <= v.first_frame + v.length * 1000) {
                $scope.currentVideo = v;
              }
            }
          }
          $scope.currentVideo == null && ($scope.currentVideo = cuts[0]);
          done = false;
          onPlayerReady = function(event){
            var firstTimestamp;
            $scope.player = event.target;
            if (playTime) {
              firstTimestamp = $scope.currentVideo.first_frame;
              $scope.player.nextStart = (playTime - firstTimestamp) / 1000;
              $scope.player.playVideo();
              playTime = null;
              return $('#player').get(0).scrollIntoView();
            }
          };
          timerId = null;
          onPlayerStateChange = function(event){
            var that, x$, timer, handler;
            if (event.data === YT.PlayerState.PLAYING && !done) {
              if (that = $scope.player.nextStart) {
                setTimeout(function(){
                  return $scope.player.seekTo(that);
                }, 50);
                $scope.player.nextStart = null;
              }
              if (timerId) {
                clearInterval(timerId);
              }
              x$ = timer = {};
              x$.current = $scope.player.getCurrentTime() * 1000;
              x$.start = new Date().getTime();
              x$.rate = $scope.player.getPlaybackRate();
              x$.now = 0;
              handler = function(){
                timer.now = new Date().getTime();
                return $scope.$apply(function(){
                  var i$, ref$, len$, w, playerOffset, results$ = [];
                  for (i$ = 0, len$ = (ref$ = $scope.waveforms).length; i$ < len$; ++i$) {
                    w = ref$[i$];
                    if (w.id === $scope.currentId) {
                      playerOffset = timer.current + (timer.now - timer.start) * timer.rate;
                      w.current = playerOffset / 1000;
                      results$.push($scope.absolutePlayerTime = moment($scope.currentVideo.first_frame + playerOffset));
                    }
                  }
                  return results$;
                });
              };
              timerId = setInterval(function(){
                return handler();
              }, 10000);
              handler();
            } else {
              if (timerId) {
                clearInterval(timerId);
              }
              timerId = null;
            }
          };
          if ($scope.player) {
            $scope.player.loadVideoById({
              videoId: $scope.currentVideo.youtube_id
            });
          } else {
            playerInit = function(){
              var firstTimestamp, start;
              if (playTime) {
                firstTimestamp = $scope.currentVideo.first_frame;
                start = (playTime - firstTimestamp) / 1000;
              }
              return new YT.Player('player', {
                height: '390',
                width: '640',
                videoId: $scope.currentVideo.youtube_id,
                playerVars: {
                  rel: 0,
                  start: start != null ? start : 0,
                  modestbranding: 1
                },
                events: {
                  onReady: onPlayerReady,
                  onStateChange: onPlayerStateChange
                }
              });
            };
            if ($scope.youtubeReady) {
              playerInit();
            } else {
              $scope.$on('youtube-ready', function(){
                return playerInit();
              });
            }
          }
          $scope.waveforms = [];
          $scope.currentId = $scope.currentVideo.youtube_id;
          mkwave = function(wave, speakers, first_frame, time, index){
            var waveclips, i$, len$, i, d;
            waveclips = [];
            for (i$ = 0, len$ = wave.length; i$ < len$; ++i$) {
              i = i$;
              d = wave[i$];
              wave[i] = d / 255;
            }
            return $scope.waveforms[index] = {
              index: index,
              id: cuts[index].youtube_id,
              wave: wave,
              speakers: speakers,
              current: 0,
              start: first_frame,
              time: time,
              cb: function(it){
                var v, ref$;
                if ($scope.currentId !== this.id) {
                  $scope.currentWaveform = this;
                  $scope.player.loadVideoById(this.id);
                  playTime = null;
                  $scope.currentId = this.id;
                  $scope.currentVideo = (function(){
                    var i$, ref$, len$, results$ = [];
                    for (i$ = 0, len$ = (ref$ = cuts).length; i$ < len$; ++i$) {
                      v = ref$[i$];
                      if (v.youtube_id === this.id) {
                        results$.push(v);
                      }
                    }
                    return results$;
                  }.call(this))[0];
                }
                if ((ref$ = $scope.player) != null) {
                  ref$.nextStart = it;
                }
                return $scope.playFrom(it);
              }
            };
          };
          return cuts.forEach(function(waveform, index){
            $http.get("http://kcwu.csie.org/~kcwu/tmp/ivod/waveform/" + waveform.wmvid + ".json").error(function(){
              return mkwave([], waveform.speakers, waveform.first_frame, waveform.time, index);
            }).success(function(wave){
              return mkwave(wave, waveform.speakers, waveform.first_frame, waveform.time, index);
            });
          });
        });
      } else {
        $scope.loaded = null;
        $scope.video = null;
        return typeof hashWatch === 'function' ? hashWatch() : void 8;
      }
    });
  })
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
function in$(x, xs){
  var i = -1, l = xs.length >>> 0;
  while (++i < l) if (x === xs[i]) return true;
  return false;
}
angular.module('ly.spy', []).directive('scrollSpy', ['$window'].concat(function($window){
  return {
    restrict: 'A',
    transclude: true,
    replace: true,
    templateUrl: 'app/spy/spy.html',
    link: function($scope, elem, attrs){
      var x$, p;
      x$ = $scope;
      x$.targets = [];
      x$.offset = +attrs.offset;
      x$.$on('spy:register', function(e, target){
        return $scope.targets.push(target);
      });
      x$.$on('repeat:finish', function(e){
        return $scope.$evalAsync(function(){
          var $anchors, $boxes;
          $anchors = elem.find(attrs.anchor);
          $boxes = elem.find(attrs.box);
          return $anchors.each(function(i){
            var $elem, $box, top;
            $elem = $(this);
            $box = $boxes.eq(i);
            top = $box.position().top;
            return $scope.targets.push({
              anchor: $elem.attr('id'),
              heading: $elem.text(),
              top: top,
              bottom: top + $box.height()
            });
          });
        });
      });
      return $window.onscroll = function(event){
        var pageY, t, i, e;
        pageY = scrollY + $scope.offset;
        for (i in $scope.targets) {
          t = $scope.targets[i];
          if (t.top <= pageY && pageY < t.bottom) {
            break;
          }
          t = null;
        }
        if (p !== t) {
          $scope.$apply(function(){
            if (p != null) {
              p.highlight = false;
            }
            return t != null ? t.highlight = true : void 8;
          });
          e = elem.find('.highlight');
          if (e.length && e.isOutOfView() && $scope.showSidebar) {
            e.scrollIntoView();
          }
        }
        return p = t;
      };
    }
  };
}));
var committees, renderCommittee;
committees = {
  IAD: '內政',
  FND: '外交及國防',
  ECO: '經濟',
  FIN: '財政',
  EDU: '教育及文化',
  TRA: '交通',
  JUD: '司法及法制',
  SWE: '社會福利及衛生環境',
  PRO: '程序'
};
renderCommittee = function(committee){
  var res, res$, i$, len$, c;
  if (committee == null) {
    return '院會';
  }
  if (committee === 'null') {
    return '院會';
  }
  if (!$.isArray(committee)) {
    committee = [committee];
  }
  res$ = [];
  for (i$ = 0, len$ = committee.length; i$ < len$; ++i$) {
    c = committee[i$];
    res$.push(("<img class=\"avatar small\" src=\"http://avatars.io/52ed1f85c747b48148000053/committee-" + c + "?size=small\" alt=\"" + committees[c] + "\">") + committees[c]);
  }
  res = res$;
  return res.join('');
};
angular.module('app.controllers', ['app.controllers.calendar', 'app.controllers.sittings', 'app.controllers.sittings-new', 'app.controllers.bills', 'app.controllers.search', 'ng']).run(['$rootScope'].concat(function($rootScope){
  return $rootScope.committees = committees;
})).controller({
  AppCtrl: ['$scope', '$location', '$rootScope', '$sce'].concat(function(s, $location, $rootScope, $sce){
    s.$location = $location;
    s.$watch('$location.path()', function(activeNavId){
      activeNavId || (activeNavId = '/');
      return s.activeNavId = activeNavId, s;
    });
    return s.getClass = function(id){
      if (s.activeNavId.substring(0, id.length === id)) {
        return 'active';
      } else {
        return '';
      }
    };
  })
}).filter('committee', ['$sce'].concat(function($sce){
  return function(value){
    return $sce.trustAsHtml(renderCommittee(value));
  };
})).controller({
  SearchFormCtrl: ['$scope', '$state'].concat(function($scope, $state){
    return $scope.submitSearch = function(){
      $state.transitionTo('search.target', {
        keyword: $scope.searchKeyword
      });
      return $scope.searchKeyword = '';
    };
  })
}).controller({
  About: ['$rootScope', '$http'].concat(function($rootScope, $http){
    return $rootScope.activeTab = 'about';
  })
}).controller({
  LYMotions: ['$rootScope', '$scope', '$state', 'LYService'].concat(function($rootScope, $scope, $state, LYService){
    var hasData;
    $rootScope.activeTab = 'motions';
    $scope.session = '8-2';
    $scope.$on('data', function(_, d){
      return $scope.$apply(function(){
        return $scope.data = d;
      });
    });
    $scope.$watch('$state.params.sitting', function(){
      var sitting;
      if (!(sitting = $state.params.sitting)) {
        $scope.sitting = null;
        return;
      }
      return $scope.$watch('data', function(it){
        if (!it) {
          return;
        }
        $scope.sitting = +sitting;
        $scope.setType('announcement');
        return $scope.setStatus(null);
      });
    });
    $scope.$on('show', function(_, sitting, type, status){
      return $scope.$apply(function(){
        $state.transitionTo('motions.sitting', {
          session: $scope.session,
          sitting: sitting
        });
        $scope.sitting = sitting;
        $scope.status = status;
        $scope.setType(type);
        return $scope.setStatus(status);
      });
    });
    import$($scope, {
      allTypes: [
        {
          key: 'announcement',
          value: '報告事項'
        }, {
          key: 'discussion',
          value: '討論事項'
        }, {
          key: 'exmotion',
          value: '臨時提案'
        }
      ],
      setType: function(type){
        var s, data, entries, allStatus, a, e, i$, len$, that, ref$, party;
        data = (function(){
          var i$, ref$, len$, results$ = [];
          for (i$ = 0, len$ = (ref$ = $scope.data).length; i$ < len$; ++i$) {
            s = ref$[i$];
            if (s.meeting.sitting === $scope.sitting) {
              results$.push(s);
            }
          }
          return results$;
        }())[0];
        entries = data[type];
        allStatus = [{
          key: 'all',
          value: '全部'
        }].concat((function(){
          var results$ = [];
          for (a in (fn$())) {
            results$.push({
              key: a,
              value: $scope.statusName(a)
            });
          }
          return results$;
          function fn$(){
            var i$, ref$, len$, ref1$, results$ = {};
            for (i$ = 0, len$ = (ref$ = entries).length; i$ < len$; ++i$) {
              e = ref$[i$];
              results$[(ref1$ = e.status) != null ? ref1$ : 'unknown'] = true;
            }
            return results$;
          }
        }()));
        if (!in$($scope.status, allStatus.map(function(it){
          return it.key;
        }))) {
          $scope.status = '';
        }
        for (i$ = 0, len$ = entries.length; i$ < len$; ++i$) {
          e = entries[i$];
          if (e.avatars == null) {
            if (that = (ref$ = e.proposer) != null ? ref$.match(/委員(.*?)(、|等)/) : void 8) {
              party = LYService.resolveParty(that[1]);
              e.avatars = [{
                party: party,
                name: that[1],
                avatar: CryptoJS.MD5("MLY/" + that[1]).toString()
              }];
            }
          }
        }
        return $scope.type = type, $scope.entries = entries, $scope.allStatus = allStatus, $scope;
      },
      setStatus: function(s){
        if (s === 'all') {
          s = '';
        }
        if (s === 'unknown') {
          s = '';
        }
        return $scope.status = s;
      },
      statusName: function(s){
        var names, ref$;
        names = {
          unknown: '未知',
          other: '其他',
          passed: '通過',
          consultation: '協商',
          retrected: '撤回',
          unhandled: '未處理',
          ey: '請行政院研處',
          prioritized: '逕付二讀',
          committee: '交委員會',
          rejected: '退回',
          accepted: '查照'
        };
        return (ref$ = names[s]) != null ? ref$ : s;
      }
    });
    return window.loadMotions($scope);
  })
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
function in$(x, xs){
  var i = -1, l = xs.length >>> 0;
  while (++i < l) if (x === xs[i]) return true;
  return false;
}
var buildAvatar, replace$ = ''.replace, toString$ = {}.toString;
buildAvatar = function(root, d, arg$, scope, LYService){
  var w, h, x, y, margin, start, that, xAxis, svg, x$;
  w = arg$.w, h = arg$.h, x = arg$.x, y = arg$.y, margin = arg$.margin;
  start = ((that = d.time)
    ? moment(that).unix()
    : -28800) * 1000;
  xAxis = d3.svg.axis().scale(x).orient("bottom").tickFormat(function(it){
    return moment(((it + start / 1000) % 86400) * 1000).format('HH:mm:ss');
  });
  svg = d3.select(root.children()[0]).attr('width', w).attr('height', h).on('click', function(){
    var x0;
    x0 = x.invert(d3.mouse(this)[0] - margin.left);
    $(svg).find('.location-marker').attr('transform', "translate(" + x0 + " " + margin.top + ")");
    return d.cb(x0);
  }).append('g').attr('transform', "translate(" + margin.left + " " + margin.top + ")");
  svg.append('g').attr('class', "x axis").attr('transform', "translate(0," + (h - margin.bottom) + ")").call(xAxis);
  svg.append('text').attr('class', 'x-legend').text(function(){
    return moment(d.time).format("YYYY/MM/DD");
  }).attr('x', function(){
    return (w + margin.left - margin.right) / 2;
  }).attr('y', function(){
    return h - margin.bottom;
  }).attr('dy', 30).attr('stroke', 'black').attr('text-anchor', "middle");
  svg.append('path').attr('class', 'location-marker').attr('d', "M0 0L0," + (h - margin.bottom - margin.top)).attr('stroke', '#f00').attr('stroke-width', '2px').attr('transform', function(){
    return "translate(" + x(d.current) + " 0)";
  });
  x$ = svg.selectAll('g.avatar').data(d.speakers).enter().append('g');
  x$.each(function(it){
    return it.color = LYService.resolvePartyColor(it.mly);
  });
  x$.attr('class', 'avatar');
  x$.attr('transform', function(it){
    return "translate(" + x(it.offset / 1000) + " 0)";
  });
  x$.on('mouseover', function(it){
    var tooltip, loc, avatar;
    tooltip = $('#avatar-tooltip');
    tooltip.show();
    loc = $(this).offset();
    loc.left -= tooltip.outerWidth() / 2;
    loc.top = root.offset().top - tooltip.outerHeight() - 5;
    $('#avatar-tooltip').offset(loc);
    avatar = CryptoJS.MD5("MLY/" + it.mly).toString();
    tooltip.find('img').attr('src', "data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAAAAAAALAAAAAABAAEAQAICRAEAOw==");
    setTimeout(function(){
      return tooltip.find('img').attr('src', "http://avatars.io/52ed1f85c747b48148000053/" + avatar + "?size=medium");
    }, 0);
    tooltip.find('.name').text(it.mly);
    return tooltip.find('.playit').on('click', function(event){
      scope.model.cb(it.offset / 1000);
      return $('#avatar-tooltip').hide();
    });
  });
  x$.append('rect').attr('width', function(it){
    var w;
    if ((w = x(it.length)) < 12) {
      return 12;
    } else {
      return w - 1;
    }
  }).attr('height', 12).style('stroke-width', '1px').style('stroke', function(it){
    return it.color;
  }).style('fill', function(it){
    return it.color;
  }).style('fill-opacity', '0.5');
  x$.append('rect').attr('width', function(it){
    var w;
    if ((w = x(it.length)) < 12) {
      return 12;
    } else {
      return w - 1;
    }
  }).attr('height', function(){
    return h - 12 - margin.bottom;
  }).attr('transform', "translate(0 12)").style('stroke-width', '1px').style('stroke', function(it){
    return it.color;
  }).style('fill', function(it){
    return it.color;
  }).style('fill-opacity', '0.2');
  x$.append('image').attr('class', "avatar small").attr('transform', "translate(1 1)").attr('width', 10).attr('height', 10).attr('xlink:href', function(it){
    var avatar;
    avatar = CryptoJS.MD5("MLY/" + it.mly).toString();
    return "http://avatars.io/52ed1f85c747b48148000053/" + avatar + "?size=small";
  }).attr('alt', function(it){
    return it.speaker;
  });
  return x$;
};
angular.module('app.directives', ['app.services']).directive('ngxResize', ['$window'].concat(function($window){
  return function(scope){
    scope.width = $window.innerWidth;
    scope.height = $window.innerHeight;
    return angular.element($window).bind('resize', function(){
      return scope.$apply(function(){
        scope.width = $window.innerWidth;
        return scope.height = $window.innerHeight;
      });
    });
  };
})).directive('ngWaveform', ['$compile', 'LYService'].concat(function($compile, LYService){
  return {
    restrict: 'E',
    replace: true,
    template: "<div class='wav-group'><svg></svg></div>",
    scope: {
      model: '=ngModel'
    },
    link: function(scope, element, attrs){
      var margin, _width, _height, _innercolor, _outercolor, ref$, w, h, x, y, x$, waveform;
      margin = {
        top: 0,
        left: 30,
        right: 30,
        bottom: 50
      };
      _width = ~~attrs.width || element.parent().width() - margin.left - margin.right;
      _height = ~~attrs.height || element.parent().height() - margin.top - margin.bottom;
      _innercolor = attrs.innercolor || '#000';
      _outercolor = attrs.outercolor || '#fff';
      ref$ = [element.width(), element.height(), null, null], w = ref$[0], h = ref$[1], x = ref$[2], y = ref$[3];
      x$ = waveform = new Waveform({
        container: element[0],
        width: _width,
        height: _height,
        innerColor: _innercolor,
        outerColor: _outercolor
      });
      x$.canvas.style.marginLeft = margin.left + "px";
      scope.$watch('model.current', function(v){
        return element.find('.location-marker').attr('transform', "translate(" + (typeof x === 'function' ? x(v) : void 8) + " " + margin.top + ")");
      });
      scope.$watch('model', function(wave){
        if (!wave) {
          return;
        }
        x = d3.scale.linear().range([0, w - margin.left - margin.right]).domain([0, wave.wave.length]);
        y = d3.scale.linear().range([h, 0]).domain([0, d3.max(wave.wave)]);
        buildAvatar(element, wave, {
          w: w,
          h: h,
          x: x,
          y: y,
          margin: margin
        }, scope, LYService);
        if (wave) {
          waveform.update({
            data: wave.wave
          });
        }
      });
    }
  };
})).directive('whenScrolled', function(){
  return function(scope, elm, attr){
    var raw;
    raw = elm[0];
    return elm.bind('scroll', function(){
      if (raw.scrollTop + raw.offsetHeight >= raw.scrollHeight) {
        return scope.$apply(attr.whenScrolled);
      }
    });
  };
}).directive('detectVisible', ['$window', '$document'].concat(function($window, $document){
  return function(scope, elm, attrs){
    var raw;
    if (!attrs.detectVisible) {
      return;
    }
    raw = elm[0];
    return angular.element($window).bind('scroll', function(){
      if (scope.stopDetect) {
        return;
      }
      if ($window.scrollY < raw.offsetTop && $window.scrollY + $window.innerHeight > raw.offsetTop) {
        return scope.$apply(attrs.detectVisible);
      }
    });
  };
})).directive('autoComplete', ['$timeout', '$state', 'LYModel', 'LYLaws'].concat(function($timeout, $state, LYModel, LYLaws){
  return function(scope, elm, attrs){
    var results, keys, resultSize;
    results = elm.parent().next();
    keys = {
      backspace: 8,
      enter: 13,
      escape: 27,
      upArrow: 38,
      downArrow: 40
    };
    scope.currentIndex = -1;
    resultSize = 7;
    elm.on('keydown', function(event){
      var keyCode, currentIndex, newIndex;
      keyCode = event.keyCode;
      currentIndex = scope.currentIndex;
      if (results.children().size() > 0) {
        if (keyCode === keys.enter) {
          if (currentIndex >= 0) {
            event.preventDefault();
            scope.searchKeyword = results.children().eq(currentIndex).text();
            return $timeout(function(){
              $state.transitionTo('search.target', {
                keyword: scope.searchKeyword
              });
              scope.searchKeyword = '';
              elm.blur();
              return scope.currentIndex = -1;
            }, 500);
          }
        } else if (keyCode === keys.upArrow) {
          results.children().removeClass('active');
          newIndex = currentIndex - 1 < 0
            ? currentIndex
            : currentIndex - 1;
          results.children().eq(newIndex).addClass('active');
          scope.currentIndex = newIndex;
          return event.preventDefault();
        } else if (keyCode === keys.downArrow) {
          results.children().removeClass('active');
          newIndex = currentIndex + 1 >= resultSize
            ? currentIndex
            : currentIndex + 1;
          results.children().eq(newIndex).addClass('active');
          scope.currentIndex = newIndex;
          return event.preventDefault();
        }
      }
    });
    return scope.$watch('searchKeyword', function(keyword){
      if (keyword) {
        return LYLaws.get(keyword, function(entries){
          var i$, len$, entry, link, result;
          results.html('');
          for (i$ = 0, len$ = entries.length; i$ < len$; ++i$) {
            entry = entries[i$];
            link = angular.element('<a>').attr('href', '/search/' + entry.name).html(entry.name);
            link.on('click', fn$);
            result = angular.element('<div>').addClass('result').append(link);
            results.append(result);
          }
          return results.show();
          function fn$(){
            scope.searchKeyword = '';
            return elm.blur();
          }
        });
      } else {
        return results.hide();
      }
    });
  };
})).directive('legislator', ['LYService', 'TWLYService', '$parse'].concat(function(LYService, TWLYService, $parse){
  return {
    restrict: 'A',
    scope: {
      legislator: '=legislator',
      style: '=legislatorStyle'
    },
    templateUrl: 'app/partials/legislator.html',
    controller: ['$scope'].concat(function($scope){
      var ref$;
      $scope.legislatorStyle = angular.copy((ref$ = $scope.style) != null
        ? ref$
        : {});
      return $scope.$watch('legislator', function(name){
        var that, party, mly, avatar, ref$, ref1$;
        if (that = /(?:本院)?(.*黨團)/.exec(name)) {
          party = LYService.parseParty(replace$.call(that[1], /黨團$/, ''));
          $scope.name = name;
          $scope.party = party;
          $scope.iconClass = party;
          return;
        }
        if ('String' === toString$.call(name).slice(8, -1)) {
          if ((mly = LYService.mlyByName(name)) != null) {
            avatar = mly.avatar;
          }
          if (mly) {
            (ref$ = $scope.legislatorStyle).infoCard == null && (ref$.infoCard = true);
          }
          if (avatar) {
            avatar += "?size=" + ((ref$ = (ref1$ = $scope.legislatorStyle) != null ? ref1$.size : void 8) != null ? ref$ : 'small');
          }
          return $scope.party = (ref$ = mly != null ? mly.party : void 8) != null ? ref$ : 'unknown', $scope.name = name, $scope.avatar = avatar, $scope.twlylink = TWLYService.getLink(name), $scope;
        } else {
          return import$($scope, $scope.legislator);
        }
      });
    })
  };
})).directive('repeatDone', function(){
  return {
    restrict: 'A',
    require: 'ng-repeat',
    controller: ['$scope'].concat(function($scope){
      if ($scope.$last) {
        return $scope.$emit("repeat:finish");
      }
    })
  };
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
angular.module('app.filters', []).filter('interpolate', ['version'].concat(function(version){
  return function(text){
    return String(text).replace(/\%VERSION\%/mg, version);
  };
}));
var replace$ = ''.replace;
angular.module('app.services', []).factory({
  LYService: ['$http'].concat(function($http){
    var mly, byName, byId;
    mly = [];
    byName = {};
    byId = {};
    return {
      init: function(){
        return $http.get('/data/mly-8.json').success(function(it){
          var i$, len$, m, results$ = [];
          mly = it;
          for (i$ = 0, len$ = mly.length; i$ < len$; ++i$) {
            m = mly[i$];
            results$.push(byName[m.name] = byId[m.id] = m);
          }
          return results$;
        });
      },
      resolveParty: function(n){
        var ref$, ref1$;
        return (ref$ = (ref1$ = byName[n]) != null ? ref1$.party : void 8) != null ? ref$ : 'unknown';
      },
      resolvePartyColor: function(n){
        return {
          KMT: '#000095',
          DPP: '#009a00',
          PFP: '#fe6407'
        }[this.resolveParty(n)] || '#999';
      },
      mlyByName: function(it){
        return byName[it];
      },
      parseParty: function(n){
        var party;
        party = (function(){
          var ref$;
          switch (ref$ = [n], false) {
          case '中國國民黨' !== ref$[0]:
            return 'KMT';
          case '國民黨' !== ref$[0]:
            return 'KMT';
          case '民主進步黨' !== ref$[0]:
            return 'DPP';
          case '民進黨' !== ref$[0]:
            return 'DPP';
          case '台灣團結聯盟' !== ref$[0]:
            return 'TSU';
          case '台灣團結聯盟' !== ref$[0]:
            return 'TSU';
          case '無黨團結聯盟' !== ref$[0]:
            return 'NSU';
          case '親民黨' !== ref$[0]:
            return 'PFP';
          case '新黨' !== ref$[0]:
            return 'NP';
          case '建國黨' !== ref$[0]:
            return 'TIP';
          case '超黨派問政聯盟' !== ref$[0]:
            return 'CPU';
          case '民主聯盟' !== ref$[0]:
            return 'DU';
          case '新國家陣線' !== ref$[0]:
            return 'NNA';
          case !/無(黨籍)?/.test(ref$[0]):
            return null;
          case '其他' !== ref$[0]:
            return null;
          default:
            return console.error(it);
          }
        }());
        return party;
      }
    };
  })
}).service({
  'TWLYService': ['LYService'].concat(function(LYService){
    var base;
    base = 'http://vote.ly.g0v.tw/voter/';
    return {
      getLink: function(name){
        var that, ref$;
        return (that = (ref$ = LYService.mlyByName(name)) != null ? ref$.id : void 8) ? base + that : void 8;
      }
    };
  })
}).service({
  'LYModel': ['$q', '$http', '$timeout'].concat(function($q, $http, $timeout){
    var config, base, _model, localGet, wrapHttpGet;
    config = require('config.jsenv');
    base = config.APIENDPOINT + "v0/collections/";
    _model = {};
    localGet = function(key){
      var deferred, promise;
      deferred = $q.defer();
      promise = deferred.promise;
      promise.success = function(fn){
        return promise.then(fn);
      };
      promise.error = function(fn){
        return promise.then(fn);
      };
      $timeout(function(){
        return deferred.resolve(_model[key]);
      });
      return promise;
    };
    wrapHttpGet = function(key, url, params){
      var req, success, error;
      req = $http.get(url, params), success = req.success, error = req.error;
      req.success = function(fn){
        return success(function(rsp){
          _model[key] = rsp;
          return fn(rsp);
        });
      };
      req.error = function(fn){
        return error(function(rsp){
          return fn(rsp);
        });
      };
      return req;
    };
    return {
      get: function(path, params){
        var url, key;
        url = base + path;
        key = params ? url + JSON.stringify(params) : url;
        key = replace$.call(key, /\"/g, '');
        return _model.hasOwnProperty(key)
          ? localGet(key)
          : wrapHttpGet(key, url, params);
      }
    };
  })
}).service({
  'LYLaws': ['$q', '$http', '$timeout'].concat(function($q, $http, $timeout){
    var config, base, _laws, init, searchLaw;
    config = require('config.jsenv');
    base = config.APIENDPOINT + "v0/collections/laws";
    _laws = [];
    init = function(){
      return $http.get(base, {
        params: {
          l: -1
        }
      }).success(function(arg$){
        var paging, entries;
        paging = arg$.paging, entries = arg$.entries;
        return _laws = _laws.concat(entries);
      });
    };
    searchLaw = function(name){
      var result, i$, ref$, len$, law;
      result = [];
      for (i$ = 0, len$ = (ref$ = _laws).length; i$ < len$; ++i$) {
        law = ref$[i$];
        if (law.name.match(name) && result.length < 7) {
          result.push(law);
        }
      }
      return result;
    };
    init();
    return {
      get: function(name, cb){
        var result;
        result = searchLaw(name);
        return cb(result);
      }
    };
  })
});
var makeLine, lineBasedDiff, charBasedDiffToDiffline, split$ = ''.split;
makeLine = function(){
  return {
    text: ''
  };
};
lineBasedDiff = function(text1, text2){
  var dmp, ds, difflines, i$, len$, line;
  dmp = new diff_match_patch;
  dmp.Diff_Timeout = 1;
  dmp.Diff_EditCost = 4;
  ds = dmp.diff_main(text1, text2);
  dmp.diff_cleanupSemantic(ds);
  difflines = charBasedDiffToDiffline(ds);
  for (i$ = 0, len$ = difflines.length; i$ < len$; ++i$) {
    line = difflines[i$];
    if (line.left === '' && line.right !== '') {
      line.state = 'insert';
    } else if (line.left !== '' && line.right === '') {
      line.state = 'delete';
    } else if (line.left !== '' && line.right !== '') {
      line.state = line.left === line.right ? 'equal' : 'replace';
    } else {
      line.state = 'empty';
    }
  }
  return difflines;
};
charBasedDiffToDiffline = function(ds){
  var left_lines, right_lines, i$, len$, ref$, target, text, lines, j$, len1$, i, line, max, ref1$, difflines, res$;
  left_lines = [makeLine()];
  right_lines = [makeLine()];
  for (i$ = 0, len$ = ds.length; i$ < len$; ++i$) {
    ref$ = ds[i$], target = ref$[0], text = ref$[1];
    target = (fn$());
    lines = split$.call(text, '\n');
    for (j$ = 0, len1$ = lines.length; j$ < len1$; ++j$) {
      i = j$;
      line = lines[j$];
      if (line !== '') {
        if (target !== 'both') {
          line = "<em>" + line + "</em>";
        }
        if (target === 'both') {
          while (left_lines.length < right_lines.length) {
            left_lines.splice(-1, 0, makeLine());
          }
          while (left_lines.length > right_lines.length) {
            right_lines.splice(-1, 0, makeLine());
          }
        }
      }
      if (target !== 'right') {
        left_lines[left_lines.length - 1].text += line;
        if (i !== lines.length - 1) {
          left_lines.push(makeLine());
        }
      }
      if (target !== 'left') {
        right_lines[right_lines.length - 1].text += line;
        if (i !== lines.length - 1) {
          right_lines.push(makeLine());
        }
      }
    }
  }
  max = (ref$ = left_lines.length) > (ref1$ = right_lines.length) ? ref$ : ref1$;
  res$ = [];
  for (i$ = 1; i$ <= max; ++i$) {
    i = i$;
    res$.push({});
  }
  difflines = res$;
  for (i$ = 0, len$ = left_lines.length; i$ < len$; ++i$) {
    i = i$;
    line = left_lines[i$];
    difflines[i].left = line.text;
  }
  for (i$ = 0, len$ = right_lines.length; i$ < len$; ++i$) {
    i = i$;
    line = right_lines[i$];
    difflines[i].right = line.text;
  }
  return difflines;
  function fn$(){
    switch (target) {
    case 0:
      return 'both';
    case 1:
      return 'right';
    case -1:
      return 'left';
    }
  }
};
if (typeof module != 'undefined' && module !== null) {
  module.exports = {
    charBasedDiffToDiffline: charBasedDiffToDiffline
  };
}