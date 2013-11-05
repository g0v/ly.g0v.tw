(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    definition(module.exports, localRequire(name), module);
    var exports = cache[name] = module.exports;
    return exports;
  };

  var require = function(name) {
    var path = expand(name, '.');

    if (has(cache, path)) return cache[path];
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex];
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '"');
  };

  var define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  globals.require = require;
  globals.require.define = define;
  globals.require.register = define;
  globals.require.brunch = true;
})();

angular.module('scroll', []).value('$anchorScroll', angular.noop);
angular.module('ly.g0v.tw', ['ngGrid', 'app.controllers', 'ly.g0v.tw.controllers', 'app.directives', 'app.filters', 'app.services', 'scroll', 'partials', 'ui.state', 'utils', 'monospaced.qrcode']).config(['$stateProvider', '$urlRouterProvider', '$locationProvider'].concat(function($stateProvider, $urlRouterProvider, $locationProvider){
  $stateProvider.state('motions', {
    url: '/motions',
    templateUrl: '/partials/motions.html',
    controller: 'LYMotions'
  }).state('motions.sitting', {
    url: '/{session}/{sitting}'
  }).state('bills', {
    url: '/bills/{billId}',
    templateUrl: '/partials/bills.html',
    resolve: {
      _init: ['LYService'].concat(function(it){
        return it.init();
      })
    },
    controller: 'LYBills'
  }).state('calendar', {
    url: '/calendar',
    templateUrl: '/partials/calendar.html',
    resolve: {
      _init: ['LYService'].concat(function(it){
        return it.init();
      })
    }
  }).state('sittings', {
    url: '/sittings',
    templateUrl: '/partials/sittings.html',
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
    templateUrl: '/partials/debates.html',
    resolve: {
      _init: ['LYService'].concat(function(it){
        return it.init();
      })
    }
  }).state('sitting', {
    url: '/sitting',
    templateUrl: '/partials/sitting.html',
    controller: 'LYSitting'
  }).state('about', {
    url: '/about',
    templateUrl: '/partials/about.html',
    controller: 'About'
  });
  $urlRouterProvider.otherwise('/calendar');
  return $locationProvider.html5Mode(true);
})).run(['$rootScope', '$state', '$stateParams', '$location'].concat(function($rootScope, $state, $stateParams, $location){
  $rootScope.$state = $state;
  $rootScope.$stateParam = $stateParams;
  $rootScope.go = function(it){
    return $location.path(it);
  };
  $rootScope._build = window.global.config.BUILD;
  $rootScope.$on('$stateChangeSuccess', function(e, arg$){
    var name;
    name = arg$.name;
    return typeof window != 'undefined' && window !== null ? typeof window.ga === 'function' ? window.ga('send', 'pageview', {
      page: $location.$$url,
      title: name
    }) : void 8 : void 8;
  });
  return window.onYouTubeIframeAPIReady = function(){
    return $rootScope.$broadcast('youtube-ready');
  };
}));
;

var buildAvatar;
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
      return tooltip.find('img').attr('src', "http://avatars.io/50a65bb26e293122b0000073/" + avatar + "?size=medium");
    }, 0);
    tooltip.find('.name').text(it.mly);
    return tooltip.find('a.btn').on('click', function(event){
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
    return "http://avatars.io/50a65bb26e293122b0000073/" + avatar + "?size=small";
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
})).directive('ngWaveform', function($compile, LYService){
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
});
;

angular.module('app.filters', []).filter('interpolate', ['version'].concat(function(version){
  return function(text){
    return String(text).replace(/\%VERSION\%/mg, version);
  };
}));
;

var replace$ = ''.replace;
angular.module('app.services', []).factory({
  LYService: ['$http'].concat(function($http){
    var mly;
    mly = [];
    return {
      init: function(){
        return $http.get('/data/mly-8.json').success(function(it){
          return mly = it;
        });
      },
      resolveParty: function(n){
        var party, name;
        party = (function(){
          var i$, ref$, len$, ref1$, results$ = [];
          for (i$ = 0, len$ = (ref$ = mly).length; i$ < len$; ++i$) {
            ref1$ = ref$[i$], party = ref1$.party, name = ref1$.name;
            if (name === n) {
              results$.push(party);
            }
          }
          return results$;
        }())[0];
        return party;
      },
      resolvePartyColor: function(n){
        return {
          KMT: '#000095',
          DPP: '#009a00',
          PFP: '#fe6407'
        }[this.resolveParty(n)] || '#999';
      }
    };
  })
}).service({
  'LYModel': ['$q', '$http', '$timeout'].concat(function($q, $http, $timeout){
    var base, _model, localGet, wrapHttpGet;
    base = 'http://api-beta.ly.g0v.tw/v0/collections/';
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
        console.log('useLocalCache');
        return deferred.resolve(_model[key]);
      });
      return promise;
    };
    wrapHttpGet = function(key, url, params){
      var req, success, error;
      req = $http.get(url, params), success = req.success, error = req.error;
      req.success = function(fn){
        return success(function(rsp){
          console.log('save response to local model');
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
});
;

var replace$ = ''.replace;
angular.module('app.controllers.calendar', []).controller({
  LYCalendar: ['$rootScope', '$scope', '$http', 'LYService', 'LYModel', '$sce'].concat(function($rootScope, $scope, $http, LYService, LYModel, $sce){
    var committees, today, i$, i, getData;
    committees = $rootScope.committees;
    $scope.type = 'sitting';
    $rootScope.activeTab = 'calendar';
    $scope.committee = function(arg$, col){
      var entity, committee, res, res$, i$, len$, c;
      entity = arg$.entity, committee = entity.committee;
      if (!committee) {
        return '院會';
      }
      res$ = [];
      for (i$ = 0, len$ = committee.length; i$ < len$; ++i$) {
        c = committee[i$];
        res$.push(("<img class=\"avatar small\" src=\"http://avatars.io/50a65bb26e293122b0000073/committee-" + c + "?size=small\" alt=\"" + committees[c] + "\">") + committees[c]);
      }
      res = res$;
      return $sce.trustAsHtml(res.join(''));
    };
    $scope.chair = function(arg$, col){
      var entity, chair, party, avatar;
      entity = arg$.entity, chair = entity.chair;
      if (!chair) {
        return '';
      }
      party = LYService.resolveParty(chair);
      avatar = CryptoJS.MD5("MLY/" + chair).toString();
      return $sce.trustAsHtml(chair + ("<img class=\"avatar small " + party + "\" src=\"http://avatars.io/50a65bb26e293122b0000073/" + avatar + "?size=small\" alt=\"" + chair + "\">"));
    };
    /* comment out this block since we are not using ng-grid.
    $scope.onair = ({{date,time}:entity}) ->
        d = moment date .startOf \day
        return false unless +today is +d
        [start,end] = if time => (time.split \~ .map -> moment "#{d.format 'YYYY-MM-DD'} #it")
        else [entity.time_start,entity.time_end]map -> moment "#{d.format 'YYYY-MM-DD'} #it"
        start <= moment! <= end
    
    $scope.gridOptions = {+showFilter, +showColumnMenu, +showGroupPanel, +enableHighlighting,
    -groupsCollapsedByDefault, +inlineAggregate, +enableRowSelection} <<< do
        groups: <[primaryCommittee]>
        rowHeight: 65
        data: \calendar
        i18n: \zh-tw
        aggregateTemplate: """
        <div ng-click="row.toggleExpand()" ng-style="rowStyle(row)" class="ngAggregate" ng-switch on="row.field">
          <span ng-switch-when="primaryCommittee" class="ngAggregateText" ng-bind-html="row.label | committee"></span>
          <span ng-switch-default class="ngAggregateText">{{row.label CUSTOM_FILTERS}} ({{row.totalChildren()}} {{AggItemsLabel}})</span>
          <div class="{{row.aggClass()}}"></div>
        </div>
        """
        columnDefs:
          * field: 'primaryCommittee'
            visible: false
            displayName: \委員會
            width: 130
            cellTemplate: """
            <div ng-bind-html="row.getProperty(col.field) | committee"></div>
            """
          * field: 'committee'
            visible: false
            displayName: \委員會
            width: 130
            cellTemplate: """
            <div ng-bind-html="row.getProperty(col.field) | committee"></div>
            """
          * field: 'chair'
            displayName: \主席
            width: 130
            cellTemplate: """
            <div ng-bind-html="chair(row)"></div>
            """
          * field: 'date'
            cellFilter: 'date: mediumDate'
            width: 100px
            displayName: \日期
          * field: 'time'
            width: 100px
            displayName: \時間
            cellTemplate: """<div ng-class="{onair: onair(row)}"><div class="ngCellText">{{row.getProperty('time_start')}}-<br/>{{row.getProperty('time_end')}}</div></div>
            """
          * field: 'name'
            displayName: \名稱
            width: 320px
            cellTemplate: """<div class="ngCellText"><a ng-href="/sittings/{{row.getProperty('sitting_id')}}">{{row.getProperty(col.field)}}</a></div>"""
          * field: 'summary'
            displayName: \議程
            cellClass: \summary
            width: '*'
    
    $scope.$watch 'height' (->
        $ '.grid' .height $scope.height - 65
        options = $scope.gridOptions
        options.$gridServices.DomUtilityService.RebuildGrid options.$gridScope, options.ngGrid
    ), false
    */
    today = moment().startOf('day');
    $scope.weeksOpts = [];
    for (i$ = 0; i$ <= 49; i$ += 7) {
      i = i$;
      $scope.weeksOpts.push(
      fn$());
    }
    $scope.weeksOpts.unshift({
      start: moment(today).add('days', -1),
      end: moment(today).add('days', 1),
      label: '今日'
    });
    $scope.weeks = $scope.weeksOpts[0];
    getData = function(){
      var ref$, start, end;
      ref$ = [$scope.weeks.start, $scope.weeks.end].map(function(it){
        return it.format("YYYY-MM-DD");
      }), start = ref$[0], end = ref$[1];
      $scope.start = $scope.weeks.start.format("YYYY-MM-DD");
      $scope.end = $scope.weeks.end.format("YYYY-MM-DD");
      return LYModel.get('calendar', {
        params: {
          s: JSON.stringify({
            date: 1,
            time: 1
          }),
          q: JSON.stringify({
            date: {
              $gt: start,
              $lt: end
            },
            type: $scope.type
          }),
          l: 1000
        }
      }).success(function(arg$){
        var paging, entries, group;
        paging = arg$.paging, entries = arg$.entries;
        group = {};
        $scope.calendar = entries.map(function(it){
          var ref$, d, start, end, key$;
          it.date = replace$.call(it.date, /Z/, '');
          it.formatDate = moment(it.date).format('MMM Do, YYYY');
          it.primaryCommittee = ((ref$ = it.committee) != null ? ref$[0] : void 8) || 'YS';
          d = moment(it.date).startOf('day');
          ref$ = it.time
            ? it.time.split('~').map(function(it){
              return moment(d.format('YYYY-MM-DD') + " " + it);
            })
            : [it.time_start, it.time_end].map(function(it){
              return moment(d.format('YYYY-MM-DD') + " " + it);
            }), start = ref$[0], end = ref$[1];
          it.onair = +today === +d && (start <= (ref$ = moment()) && ref$ <= end);
          group[key$ = it.primaryCommittee] == null && (group[key$] = []);
          return group[it.primaryCommittee].push(it);
        });
        return $scope.group = group;
      });
    };
    $scope.$watch('weeks', getData);
    return $scope.change = function(type){
      $scope.type = type;
      getData();
    };
    function fn$(){
      var opt;
      opt = {
        start: moment(today).day(0 - i),
        end: moment(today).day(0 - i + 7)
      };
      return opt.label = opt.start.format("YYYY:  MM-DD" + ' to ' + opt.end.format("MM-DD")), opt;
    }
  })
});
;

(function() {
  var module = {};
  module.exports = {"BUILD":"git-unknown"};
  if (!window.global)
    window.global = {};
  window.global['config'] = module.exports;
}).call(this);

angular.module('ly.g0v.tw.controllers', ['ng']).controller({
  LYDebates: ['$rootScope', '$scope', '$http', 'LYService', '$sce'].concat(function($rootScope, $scope, $http, LYService, $sce){
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
    $scope.mly = function(arg$){
      var entity, mly, party, avatar;
      entity = arg$.entity, mly = entity.mly;
      if (!mly[0]) {
        return '';
      }
      party = LYService.resolveParty(mly[0]);
      avatar = CryptoJS.MD5("MLY/" + mly[0]).toString();
      return $sce.trustAsHtml(mly[0] + ("<img class=\"avatar small " + party + "\" src=\"http://avatars.io/50a65bb26e293122b0000073/" + avatar + "?size=small\" alt=\"" + mly[0] + "\">"));
    };
    padLeft = function(str, length){
      if (str.length >= length) {
        return str;
      }
      return padLeft('0' + str, length);
    };
    $scope.source = function(arg$){
      var entity, source, link, str, href;
      entity = arg$.entity, source = entity.source, link = source.link;
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
        if (!value.source.text.match(/口頭答復/)) {
          link = value.source.link;
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
      rowHeight: 80,
      data: 'debates',
      pagingOptions: $scope.pagingOptions,
      i18n: 'zh-tw',
      columnDefs: [
        {
          field: 'tts_id',
          displayName: '系統號',
          width: 80
        }, {
          field: 'mly',
          displayName: '質詢人',
          width: 130,
          cellTemplate: "<div ng-bind-html=\"mly(row)\"></div>"
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
          field: 'debate_type',
          displayName: '質詢性質',
          width: '*'
        }
      ]
    });
    $scope.getData = function(arg$){
      var currentPage, pageSize;
      currentPage = arg$.currentPage, pageSize = arg$.pageSize;
      return $http.get('http://api.ly.g0v.tw/v0/collections/debates', {
        params: {
          sk: (currentPage - 1) * pageSize,
          l: pageSize
        }
      }).success(function(arg$){
        var paging, entries;
        paging = arg$.paging, entries = arg$.entries;
        angular.forEach(entries, function(value, key){
          value.date_asked = new Date(value.date_asked);
          value.source = JSON.parse(value.source);
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
  first = true;
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
;

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
;

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
;

var ctemplate, renderConversation, render, renderYs, slice$ = [].slice;
ctemplate = require('view/ys/conversation');
renderConversation = function(conversation){
  return ctemplate({
    conversation: conversation,
    renderConversation: renderConversation
  });
};
render = function(node, type, content){
  var i$, ref$, len$, ref1$, entries, name, results$ = [];
  switch (type) {
  case 'Announcement':
    node.append(
    require('view/ys/announcement')(
    {
      content: content,
      renderConversation: renderConversation
    }));
    return $('.sidebarnav').append($("<ul><li><a href='#announcement'>報告事項</a><li/></ul>").html());
  case 'Interpellation':
    node.append(
    require('view/ys/interpellation')(
    {
      content: content,
      renderConversation: renderConversation
    }));
    $('.sidebarnav').append($("<ul><li><a href='#interpellation'>質詢事項</a><li/></ul>").html());
    for (i$ = 0, len$ = (ref$ = content.interpellation).length; i$ < len$; ++i$) {
      ref1$ = ref$[i$], type = ref1$[0], entries = ref1$[1];
      if (type === 'interp') {
        name = entries[0][0];
        results$.push($('.sidebarnav').append($("<ul><li><a scrollto href='#interpellation-" + name + "'>" + name + "</a><li/></ul>").html()));
      }
    }
    return results$;
    break;
  default:
    return node.append(renderConversation({
      conversation: [type, content]
    }));
  }
};
renderYs = function(node, data){
  var meta, log, i$, len$, entry, refresh;
  meta = data.meta, log = data.log;
  node.append(
  require('view/ys/meta')(
  meta));
  for (i$ = 0, len$ = log.length; i$ < len$; ++i$) {
    entry = log[i$];
    render.apply(null, [node].concat(slice$.call(entry)));
  }
  $('[data-spy="affix"]').affix();
  refresh = function(){
    return $('[data-spy="scroll"]').each(function(){
      return $(this).scrollspy('refresh');
    });
  };
  $('.collapse').on('hidden', refresh);
  return refresh();
};
window.init = function(){
  return $.get('/data/yslog/ly-4004.json', {
    type: 'json'
  }, function(data){
    return renderYs($('.content'), data);
  });
};
;

var committees, renderCommittee, lineBasedDiff, split$ = ''.split, slice$ = [].slice, replace$ = ''.replace;
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
    res$.push(("<img class=\"avatar small\" src=\"http://avatars.io/50a65bb26e293122b0000073/committee-" + c + "?size=small\" alt=\"" + committees[c] + "\">") + committees[c]);
  }
  res = res$;
  return res.join('');
};
lineBasedDiff = function(text1, text2){
  var dmp, ds, makeLineObject, isLeft, isRight, difflines, last_left, last_right, i$, len$, ref$, target, text, lines, j$, len1$, i, line;
  dmp = new diff_match_patch;
  dmp.Diff_Timeout = 1;
  dmp.Diff_EditCost = 4;
  ds = dmp.diff_main(text1, text2);
  dmp.diff_cleanupSemantic(ds);
  makeLineObject = function(){
    return {
      left: '',
      right: ''
    };
  };
  isLeft = function(target){
    return target !== 'right';
  };
  isRight = function(target){
    return target !== 'left';
  };
  difflines = [makeLineObject()];
  last_left = last_right = 0;
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
        if (isLeft(target)) {
          difflines[last_left].left += line;
        }
        if (isRight(target)) {
          difflines[last_right].right += line;
        }
      }
      if (i !== lines.length - 1) {
        difflines.push(makeLineObject());
        if (isLeft(target)) {
          last_left = difflines.length - 1;
        }
        if (isRight(target)) {
          last_right = difflines.length - 1;
        }
      }
    }
  }
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
angular.module('app.controllers', ['app.controllers.calendar', 'ng']).run(['$rootScope'].concat(function($rootScope){
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
  LYBills: ['$scope', '$http', '$state', 'LYService', '$sce'].concat(function($scope, $http, $state, LYService, $sce){
    $scope.diffs = [];
    $scope.diffstate = function(left_right, state){
      switch (false) {
      case !(left_right === 'left' && state !== 'equal'):
        return 'red';
      case !(deepEq$(state, 'replace', '===') || deepEq$(state, 'empty', '===') || deepEq$(state, 'insert', '===') || deepEq$(state, 'delete', '===')):
        return 'green';
      default:
        return '';
      }
    };
    $scope.difftxt = function(left_right, state){
      switch (false) {
      case !(left_right === 'left' && state !== 'equal'):
        return '現行';
      case !(deepEq$(state, 'replace', '===') || deepEq$(state, 'empty', '===')):
        return '修正';
      case !deepEq$(state, 'delete', '==='):
        return '刪除';
      case !deepEq$(state, 'insert', '==='):
        return '新增';
      default:
        return '相同';
      }
    };
    return $scope.$watch('$state.params.billId', function(){
      var billId;
      billId = $state.params.billId;
      return $http.get("http://api-beta.ly.g0v.tw/v0/collections/bills/" + billId).success(function(bill){
        var committee;
        committee = bill.committee;
        if (bill.bill_ref && bill.bill_ref !== billId) {
          return $state.transitionTo('bills', {
            billId: bill.bill_ref
          });
        }
        $state.current.title = "ly.g0v.tw - " + (bill.bill_ref || bill.bill_id) + " - " + bill.summary;
        return $http.get("http://api-beta.ly.g0v.tw/v0/collections/bills/" + billId + "/data").success(function(data){
          var committee, parseArticleHeading, diffentry, ref$;
          if (committee) {
            committee = committee.map(function(it){
              return {
                abbr: it,
                name: committees[it]
              };
            });
          }
          parseArticleHeading = function(text){
            var ref$, _, _items, zhutil;
            if ((ref$ = text.match(/第(.+)條(?:之(.+))?/)) != null) {
              _ = ref$[0], _items = slice$.call(ref$, 1);
            }
            if (!_items) {
              return;
            }
            zhutil = require('zhutil');
            return '§' + _items.filter(function(it){
              return it;
            }).map(zhutil.parseZHNumber).join('-');
          };
          diffentry = function(diff, idx, c, baseIndex){
            return function(entry){
              var h, comment, baseTextLines, leftItem, newTextLines, rightItem, difflines;
              h = diff.header;
              comment = 'string' === typeof entry[c]
                ? entry[c]
                : entry[c][h[idx].replace(/審查會通過條文/, '審查會')];
              if (comment) {
                comment = comment.replace(/\n/g, "<br><br>\n");
              }
              baseTextLines = entry[baseIndex] || '';
              if (baseTextLines) {
                baseTextLines = replace$.call(baseTextLines, /^第(.*?)條(之.*?)?\s+/, '');
                leftItem = parseArticleHeading(replace$.call(RegExp.lastMatch, /\s+$/, ''));
              }
              newTextLines = entry[idx] || entry[baseIndex];
              newTextLines = replace$.call(newTextLines, /^第(.*?)條(之.*?)?\s+/, '');
              rightItem = parseArticleHeading(replace$.call(RegExp.lastMatch, /\s+$/, ''));
              difflines = lineBasedDiff(baseTextLines, newTextLines);
              angular.forEach(difflines, function(value, key){
                value.left = $sce.trustAsHtml(value.left);
                return value.right = $sce.trustAsHtml(value.right);
              });
              comment = $sce.trustAsHtml(comment);
              return {
                comment: comment,
                difflines: difflines,
                leftItem: leftItem,
                rightItem: rightItem
              };
            };
          };
          return import$(($scope.summary = bill.summary, $scope.abstract = bill.abstract, $scope.bill_ref = bill.bill_ref, $scope.doc = bill.doc, $scope), {
            committee: committee,
            related: bill.committee ? data != null ? (ref$ = data.related) != null ? ref$.map(function(arg$){
              var id, summary, ref$, _, mly;
              id = arg$[0], summary = arg$[1];
              return import$({
                id: id,
                summary: summary
              }, (ref$ = summary.match(/本院委員(.*?)等/)) != null && (_ = ref$[0], mly = ref$[1], ref$)
                ? {
                  party: LYService.resolveParty(mly),
                  avatar: CryptoJS.MD5("MLY/" + mly).toString(),
                  name: mly
                }
                : {});
            }) : void 8 : void 8 : void 8,
            sponsors: (ref$ = bill.sponsors) != null ? ref$.map(function(it){
              var party;
              party = LYService.resolveParty(it);
              return {
                party: party,
                name: it,
                avatar: CryptoJS.MD5("MLY/" + it).toString()
              };
            }) : void 8,
            cosponsors: (ref$ = bill.cosponsors) != null ? ref$.map(function(it){
              var party;
              party = LYService.resolveParty(it);
              return {
                party: party,
                name: it,
                avatar: CryptoJS.MD5("MLY/" + it).toString()
              };
            }) : void 8,
            setDiff: function(diff, version){
              var i, n, idx, baseIndex, c;
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
              return import$(diff, {
                diffnew: version,
                diffcontent: diff.content.map(diffentry(diff, idx, c, baseIndex))
              });
            },
            diff: data != null ? (ref$ = data.content) != null ? ref$.map(function(diff){
              var h, i, n, baseIndex, c;
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
                diffcontent: diff.content.map(diffentry(diff, 0, c, baseIndex))
              });
            }) : void 8 : void 8
          });
        });
      });
    });
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
}).controller({
  LYSittings: ['$rootScope', '$scope', '$http', '$state', 'LYService', 'LYModel'].concat(function($rootScope, $scope, $http, $state, LYService, LYModel){
    var loadList, loadSitting, getMotionsInType, hashWatch;
    $rootScope.activeTab = 'sittings';
    $scope.committees = committees;
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
            "ad": 8,
            "committee": type
          },
          l: length,
          f: {
            "motions": 0
          }
        }
      }).success(function(arg$){
        var entries;
        entries = arg$.entries;
        $scope.loadingList = false;
        $scope.lists[$scope.context] = entries;
        return $scope.currentList = $scope.lists[$scope.context];
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
        var entries, allStatus, a, e, i$, len$, that, ref$, party;
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
            if (that = (ref$ = e.proposed_by) != null ? ref$.match(/委員(.*?)(、|等)/) : void 8) {
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
        return LYModel.get("sittings/" + $state.params.sitting + "/videos").success(function(videos){
          var whole, res$, i$, len$, v, ref$, firstTimestamp, clips, YOUTUBE_APIKEY;
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
          if (playTime) {
            for (i$ = 0, len$ = whole.length; i$ < len$; ++i$) {
              v = whole[i$];
              if (playTime.format("YYYY-MM-DD") === v.first_frame.format("YYYY-MM-DD")) {
                $scope.currentVideo = v;
              }
            }
          } else {
            $scope.currentVideo = whole[0];
          }
          firstTimestamp = $scope.currentVideo.first_frame;
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
          YOUTUBE_APIKEY = 'AIzaSyDT6AVKwNjyWRWtVAdn86Q9I7HXJHG11iI';
          return $http.get("https://www.googleapis.com/youtube/v3/videos?id=" + $scope.currentVideo.youtube_id + "&key=" + YOUTUBE_APIKEY + "&part=snippet,contentDetails,statistics,status").success(function(details){
            var that, ref$, _, h, m, s, duration, done, onPlayerReady, timerId, onPlayerStateChange, playerInit, mkwave;
            if (that = (ref$ = details.items) != null ? ref$[0] : void 8) {
              ref$ = that.contentDetails.duration.match(/^PT(\d+H)?(\d+M)?(\d+S)/), _ = ref$[0], h = ref$[1], m = ref$[2], s = ref$[3];
              duration = (parseInt(h) * 60 + parseInt(m)) * 60 + parseInt(s);
            }
            done = false;
            onPlayerReady = function(event){
              $scope.player = event.target;
              if (playTime) {
                $scope.player.nextStart = (playTime - firstTimestamp) / 1000;
                $scope.player.playVideo();
                return $('#player').get(0).scrollIntoView();
              }
            };
            timerId = null;
            onPlayerStateChange = function(event){
              var that, x$, timer, handler;
              if (event.data === YT.PlayerState.PLAYING && !done) {
                if (that = $scope.player.nextStart) {
                  $scope.player.seekTo(that);
                  $scope.player.nextStart = null;
                }
                if (timerId) {
                  clearInterval(timerId);
                }
                x$ = timer = {};
                x$.sec = $scope.player.getCurrentTime();
                x$.start = new Date().getTime() / 1000;
                x$.rate = $scope.player.getPlaybackRate();
                x$.now = 0;
                handler = function(){
                  timer.now = new Date().getTime() / 1000;
                  return $scope.$apply(function(){
                    return $scope.waveforms[0].current = timer.sec + (timer.now - timer.start) * timer.rate;
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
                return new YT.Player('player', {
                  height: '390',
                  width: '640',
                  videoId: $scope.currentVideo.youtube_id,
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
            mkwave = function(wave, speakers, time, index){
              var waveclips, i$, len$, i, d;
              waveclips = [];
              for (i$ = 0, len$ = wave.length; i$ < len$; ++i$) {
                i = i$;
                d = wave[i$];
                wave[i] = d / 255;
              }
              return $scope.waveforms[index] = {
                id: whole[index].youtube_id,
                wave: wave,
                speakers: speakers,
                current: 0,
                start: firstTimestamp,
                time: time,
                cb: function(it){
                  return $scope.playFrom(it);
                }
              };
            };
            return whole.forEach(function(waveform, index){
              var start, ref$, day_start, speakers, i$, len$, clip;
              start = (ref$ = waveform.first_frame_timestamp) != null
                ? ref$
                : waveform.time;
              day_start = +moment(start).startOf('day');
              speakers = clips.filter(function(it){
                return +moment(it.time).startOf('day') === day_start;
              });
              for (i$ = 0, len$ = speakers.length; i$ < len$; ++i$) {
                clip = speakers[i$];
                clip.offset = moment(clip.time) - moment(start);
              }
              $http.get("http://kcwu.csie.org/~kcwu/tmp/ivod/waveform/" + waveform.wmvid + ".json").error(function(){
                return mkwave([], index);
              }).success(function(wave){
                return mkwave(wave, speakers, waveform.time, index);
              });
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
}).controller({
  LYSitting: ['$rootScope', '$scope', '$http'].concat(function($rootScope, $scope, $http){
    return $http.get('/data/yslog/ly-4004.json').success(function(data){
      var patterns, parse, i$, ref$, len$, entry, results$ = [];
      $rootScope.activeTab = 'sitting';
      $scope.json = data;
      $scope.meta = data.meta;
      $scope.meta.map = [];
      patterns = {
        "立法院公報": /^立法院公報　/,
        "主席": /^主　+席　/,
        "時間": /^時　+間　/,
        "地點": /^地　+點　/
      };
      data.meta.raw.forEach(function(v, i, a){
        var type, ref$, pattern, key;
        for (type in ref$ = patterns) {
          pattern = ref$[type];
          if (v.match(pattern)) {
            v = v.replace(pattern, "");
            key = type;
            break;
          } else {
            key = "";
          }
        }
        return data.meta.map.push({
          key: key,
          value: v
        });
      });
      $scope.annoucement = [];
      $scope.interpellation = {
        answers: [],
        questions: [],
        interpellations: []
      };
      $scope.interp = [];
      parse = function(type, content){
        var idx, entry, section, i$, ref$, len$, ref1$, speaker, words, _, receiver, asker, entries, lresult$, j$, len1$, results$ = [];
        switch (type) {
        case 'Announcement':
          $scope.Announcement = content;
          for (idx in content) {
            entry = content[idx];
            section = {
              subject: entry.subject,
              conversation: []
            };
            for (i$ = 0, len$ = (ref$ = entry.conversation).length; i$ < len$; ++i$) {
              ref1$ = ref$[i$], speaker = ref1$[0], words = ref1$[1];
              section.conversation.push({
                speaker: speaker,
                words: words
              });
            }
            results$.push($scope.annoucement.push(section));
          }
          return results$;
          break;
        case 'Interpellation':
          for (_ in ref$ = content.answers) {
            ref1$ = ref$[_], receiver = ref1$[0], words = ref1$[1];
            $scope.interpellation.answers.push({
              receiver: receiver,
              words: words
            });
          }
          for (_ in ref$ = content.questions) {
            ref1$ = ref$[_], asker = ref1$[0], words = ref1$[1];
            $scope.interpellation.questions.push({
              asker: asker,
              words: words
            });
          }
          for (i$ = 0, len$ = (ref$ = content.interpellation).length; i$ < len$; ++i$) {
            ref1$ = ref$[i$], type = ref1$[0], entries = ref1$[1];
            if (type === 'interp') {
              $scope.interp.push(entries);
            }
          }
          for (i$ = 0, len$ = (ref$ = content.interpellation).length; i$ < len$; ++i$) {
            ref1$ = ref$[i$], type = ref1$[0], entries = ref1$[1];
            lresult$ = [];
            if (type === 'interp' || type === 'interpdoc' || type === 'exmotion') {
              section = {
                questioner: entries[0][0],
                conversation: []
              };
              for (j$ = 0, len1$ = entries.length; j$ < len1$; ++j$) {
                ref1$ = entries[j$], speaker = ref1$[0], words = ref1$[1];
                section.conversation.push({
                  speaker: speaker,
                  words: words
                });
              }
            } else {
              section = {
                questioner: null,
                conversation: [{
                  speaker: type,
                  words: entries
                }]
              };
            }
            lresult$.push($scope.interpellation.interpellations.push(section));
            results$.push(lresult$);
          }
          return results$;
          break;
        default:
          return $scope.otherwise = content;
        }
      };
      for (i$ = 0, len$ = (ref$ = data.log).length; i$ < len$; ++i$) {
        entry = ref$[i$];
        results$.push(parse.apply(null, entry));
      }
      return results$;
    });
  })
});
function deepEq$(x, y, type){
  var toString = {}.toString, hasOwnProperty = {}.hasOwnProperty,
      has = function (obj, key) { return hasOwnProperty.call(obj, key); };
  first = true;
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
function in$(x, arr){
  var i = -1, l = arr.length >>> 0;
  while (++i < l) if (x === arr[i] && i in arr) return true;
  return false;
}
;

