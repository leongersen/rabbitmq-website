<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE stylesheet [
<!ENTITY % entities SYSTEM "rabbit.ent">
%entities;
]>
<!--
Copyright (c) 2007-2019 Pivotal Software, Inc.

All rights reserved. This program and the accompanying materials
are made available under the terms of the under the Apache License, 
Version 2.0 (the "License”); you may not use this file except in compliance 
with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:x="http://www.rabbitmq.com/2011/extensions"
                              xmlns:c="http://www.rabbitmq.com/namespaces/ad-hoc/conformance"
                              exclude-result-prefixes="x c">

  <xsl:import href="page.xsl" />

  <xsl:output method="html" indent="yes"/>

  <xsl:variable name="spec-doc" select="document('resources/specs/amqp0-9-1.extended.xml')"/>
  <xsl:variable name="specification" select="document('specification.xml')" />
  <xsl:key name="method-key" match="c:method" use="@name" />
  <xsl:variable name="decorations" select="document('')/xsl:stylesheet/x:decorations" />
  <xsl:variable name="method-decorations" select="$decorations/x:decorate[@target='method']"/>
  <xsl:variable name="javadoc-root" select="'&dir-current-javadoc;com/rabbitmq/client/'"/>
  <xsl:variable name="dotnetdoc-root" select="'&url-dotnet-apidoc;/'"/>

  <xsl:key name="domain-key" match="domain" use="@name"/>

  <xsl:template match="x:insert-spec-here">
    <div id="container">
      <p>
        This page provides a guide to RabbitMQ's implementation of AMQP 0-9-1. In addition to the classes
        and methods defined in the <a href="specification.html">AMQP specification</a>, RabbitMQ supports several
        <a href="extensions.html">protocol extensions</a>, which are also listed here. The original and extended
        specification downloads can be found on the <a href="protocol.html">protocol page</a>.
      </p>
      <p>
        A brief <a href="/tutorials/amqp-concepts.html">AMQP 0-9-1 overview</a> is also available.
      </p>
      <p>
        For your convenience, links are provided from this guide to the relevant sections of the API guides
        for the RabbitMQ <a href="api-guide.html">Java</a> and <a href="dotnet-api-guide.html">.NET</a> clients. Full
        details of each method and its parameters are available in our <a href="amqp-0-9-1-reference.html">complete
        AMQP 0-9-1 reference</a>.
      </p>
      <!-- switch context from source file to spec doc -->
      <xsl:for-each select="$spec-doc/amqp">
        <xsl:comment>
          <xsl:value-of select="concat(' autogenerated from ', @comment)" />
        </xsl:comment>

        <xsl:apply-templates select="class[not(@name = 'connection')]">
          <xsl:sort select="@name" data-type="text" order="ascending" />
        </xsl:apply-templates>
      </xsl:for-each>
      <xsl:if test="not($spec-doc/amqp)">
        <p/>
        <em>Oops! Failed to load amqp-0-9-1.xml source file</em>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="in-this-page">
    <div class="in-this-page">
      <h4>In This Page</h4>
      <ul>
        <xsl:for-each select="$spec-doc/amqp">
          <xsl:apply-templates select="class[not(@name = 'connection')]" mode="toc">
            <xsl:sort select="@name" data-type="text" order="ascending"/>
          </xsl:apply-templates>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="class" mode="toc">
    <li>
      <a href="{concat('#class.', @name)}">
        <xsl:value-of select="@name"/>
      </a>
      <ul>
        <xsl:apply-templates select="method[not(contains(@name, '-ok'))][not(@name = 'get-empty')]" mode="toc">
          <xsl:sort select="@name" data-type="text" order="ascending"/>
        </xsl:apply-templates>
      </ul>
    </li>
  </xsl:template>

  <xsl:template match="method" mode="toc">
    <li>
      <xsl:variable name="method-qname" select="concat(../@name, '.', @name)"/>
      <a href="{concat('#', $method-qname)}">
        <xsl:value-of select="$method-qname" />
      </a>
    </li>
  </xsl:template>

  <xsl:template match="class">
    <!-- note: connection class is omitted completely -->
    <!-- note: class fields (i.e. basic) omitted -->
    <!-- note: return methods (e.g. xxx-ok and basic.get-empty) omitted for clarity -->
    <h3 id="{concat('class.', @name)}" class="class">
      <xsl:call-template name="capitalise">
        <xsl:with-param name="s" select="@name"/>
      </xsl:call-template>
    </h3>
    <xsl:if test="$decorations/x:decorate[@target = 'class'][@name = current()/@name]/x:amqp-extension">
      <h5 class="amqp-extension">THIS CLASS IS A RABBITMQ-SPECIFIC EXTENSION OF AMQP</h5>
    </xsl:if>
    <xsl:apply-templates select="method[not(contains(@name, '-ok'))][not(@name = 'get-empty')]">
      <xsl:sort select="@name" data-type="text" order="ascending" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="method">
    <xsl:variable name="qname" select="concat(../@name, '.', @name)" />
    <xsl:variable name="decorations" select="$method-decorations[@name=$qname]"/>
    <div class="method-box" id="{$qname}">
      <h4 class="method">
        <span title="{@label}">
          <span class="class-name">
            <xsl:value-of select="concat(../@name, '.')"/>
          </span>
          <span class="method-name">
            <xsl:value-of select="@name"/>
          </span>
        </span>
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="field" mode="render-method-sig"/>
        <xsl:text>)</xsl:text>
        <xsl:if test="response">
          <span class="method-retval">
            <xsl:text>&#xA0;&#x2794;&#xA0;</xsl:text>
            <xsl:apply-templates select="response" mode="render-method-sig"/>
          </span>
        </xsl:if>
      </h4>
      <xsl:for-each select="$decorations">
        <xsl:if test="x:amqp-extension">
          <h5 class="amqp-extension">THIS METHOD IS A RABBITMQ-SPECIFIC EXTENSION OF AMQP</h5>
        </xsl:if>
        <xsl:if test="x:field[@override]">
          <h5 class="amqp-extension"><span class="override">*</span> RABBITMQ-SPECIFIC EXTENSION OF AMQP</h5>
        </xsl:if>
      </xsl:for-each>
      <!-- get the implementation status from the specification page -->
      <xsl:for-each select="$specification">
        <xsl:for-each select="key('method-key', $qname)">
          <p style="float: right; margin: 0"><em>Support: </em>
            <xsl:variable name="status" select="current()/c:status/@value"/>
            <a href="{concat('specification.html#method-status-', $qname)}">
              <xsl:choose>
                <xsl:when test="$status = 'ok'">full</xsl:when>
                <xsl:otherwise><xsl:value-of select="$status" /></xsl:otherwise>
              </xsl:choose>
            </a>
          </p>
        </xsl:for-each>
      </xsl:for-each>
      <p>
        <xsl:call-template name="capitalise">
          <xsl:with-param name="s" select="@label"/>
        </xsl:call-template>
        <xsl:text>.</xsl:text>
      </p>
      <p>
        <xsl:value-of select="doc[1][not(@type)]"/>
      </p>
      <!-- apply method decorations -->
      <xsl:apply-templates select="$decorations"/>
      <xsl:if test="parent::class">
        <a href="{concat('amqp-0-9-1-reference.html#', $qname)}" class="amqp-doc">[amqpdoc]</a>
      </xsl:if>
      <xsl:call-template name="render-back-to-top"/>
    </div>
  </xsl:template>

  <xsl:template match="field" mode="render-method-sig">
    <xsl:variable name="method-qname" select="concat(../../@name, '.', ../@name)"/>
    <xsl:variable name="override" select="$method-decorations[@name = $method-qname]/x:field[@override = current()/@name]"/>
    <xsl:variable name="domain" select="$override/@domain | @domain | @type"/>
    <xsl:variable name="name" select="$override/@name | @name"/>
    <xsl:variable name="label" select="$override/@label | @label"/>

    <a href="{concat('amqp-0-9-1-reference.html#', ../../@name, '.', ../@name, '.', @name)}">
      <span class="parameter">
        <xsl:if test="$domain">
          <span class="data-type" title="{key('domain-key', $domain)/@type}">
            <xsl:value-of select="$domain"/>
          </span>
          <xsl:text>&#xA0;</xsl:text>
        </xsl:if>
        <span class="param-name" title="{$label}">
          <xsl:value-of select="$name"/>
        </span>
        <xsl:if test="$override">
          <span class="override">*</span>
        </xsl:if>
      </span>
    </a>
    <xsl:if test="position() != last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="response" mode="render-method-sig">
    <xsl:value-of select="@name" />
    <xsl:if test="position() != last()">
      <xsl:text> | </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-back-to-top">
    <a href="#top" class="back">(back to top)</a>
  </xsl:template>

  <xsl:template name="capitalise">
    <xsl:param name="s"/>
    <xsl:variable name="first" select="translate(substring($s, 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
    <xsl:value-of select="concat($first, substring($s, 2))"/>
  </xsl:template>

  <!-- templates to process 'decorations' to the specification -->

  <xsl:template match="x:javadoc">
    <a href="{concat($javadoc-root, @href)}" class="javadoc">[javadoc]</a>
  </xsl:template>

  <xsl:template match="x:dotnetdoc">
    <a href="{concat($dotnetdoc-root, @href)}" class="dotnetdoc">[dotnetdoc]</a>
  </xsl:template>

  <xsl:template match="x:url">
    <a href="{@href}" class="doc">
      <xsl:value-of select="@label"/>
    </a>
  </xsl:template>

  <xsl:template match="x:doc">
    <div class="doc">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="x:doc/*[namespace-uri() = 'http://www.w3.org/1999/xhtml']">
    <xsl:element name="{local-name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates />
    </xsl:element>
  </xsl:template>

  <xsl:template match="x:*">
    <!-- override default behaviour -->
    <xsl:apply-templates/>
  </xsl:template>

  <x:decorations>
    <x:decorate target="method" name="basic.ack">
      <x:javadoc href="Channel.html#basicAck(long, boolean)"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_BasicAck_System_UInt64_System_Boolean_"/>
    </x:decorate>
    <x:decorate target="method" name="basic.cancel">
      <x:javadoc href="Channel.html#basicCancel(java.lang.String)"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_BasicCancel_System_String_"/>
    </x:decorate>
    <x:decorate target="method" name="basic.consume">
      <x:javadoc href="Channel.html#basicConsume(java.lang.String, boolean, java.lang.String, boolean, boolean, java.util.Map, com.rabbitmq.client.Consumer)" />
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_BasicConsume_System_String_System_Boolean_System_String_System_Boolean_System_Boolean_System_Collections_Generic_IDictionary_System_String_System_Object__RabbitMQ_Client_IBasicConsumer_" />
    </x:decorate>
    <x:decorate target="method" name="basic.deliver">
      <!-- x:javadoc ***not impl*** -->
      <!-- x:dotnetdoc ***not impl*** -->
    </x:decorate>
    <x:decorate target="method" name="basic.get">
      <x:javadoc href="Channel.html#basicGet(java.lang.String, boolean)"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_BasicGet_System_String_System_Boolean_"/>
    </x:decorate>
    <x:decorate target="method" name="basic.nack">
      <x:amqp-extension />
      <x:url href="http://www.rabbitmq.com/nack.html" label="RabbitMQ Documentation"/>
      <x:javadoc href="Channel.html#basicNack(long, boolean, boolean)"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_BasicNack_System_UInt64_System_Boolean_System_Boolean_"/>
    </x:decorate>
    <x:decorate target="method" name="basic.publish">
      <x:javadoc href="Channel.html#basicPublish(java.lang.String, java.lang.String, boolean, boolean, com.rabbitmq.client.AMQP.BasicProperties, byte[])"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_BasicPublish_System_String_System_String_System_Boolean_RabbitMQ_Client_IBasicProperties_System_Byte___"/>
    </x:decorate>
    <x:decorate target="method" name="basic.qos">
      <x:javadoc href="Channel.html#basicQos(int, int, boolean)"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_BasicQos_System_UInt32_System_UInt16_System_Boolean_"/>
    </x:decorate>
    <x:decorate target="method" name="basic.recover">
      <x:javadoc href="Channel.html#basicRecover(boolean)"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_BasicRecover_System_Boolean_"/>
    </x:decorate>
    <x:decorate target="method" name="basic.recover-async">
      <x:javadoc href="Channel.html#basicRecoverAsync(boolean)"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_BasicRecoverAsync_System_Boolean_"/>
    </x:decorate>
    <x:decorate target="method" name="basic.reject">
      <x:url href="http://www.rabbitmq.com/blog/2010/08/03/well-ill-let-you-go-basicreject-in-rabbitmq/" label="RabbitMQ blog post"/>
      <x:javadoc href="Channel.html#basicReject(long, boolean)"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_BasicReject_System_UInt64_System_Boolean_"/>
    </x:decorate>
    <x:decorate target="method" name="basic.return">
      <!-- x:javadoc ***not impl*** -->
      <!-- x:dotnetdoc ***not impl*** -->
    </x:decorate>
    <x:decorate target="method" name="channel.close">
      <x:javadoc href="Channel.html#close(int, java.lang.String)"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_Close"/>
    </x:decorate>
    <x:decorate target="method" name="channel.open">
      <!-- x:javadoc ***not impl*** -->
      <!-- x:dotnetdoc ***not impl*** -->
    </x:decorate>
    <x:decorate target="class" name="confirm">
      <x:amqp-extension />
    </x:decorate>
    <x:decorate target="method" name="confirm.select">
      <x:url href="http://www.rabbitmq.com/confirms.html" label="RabbitMQ Documentation"/>
      <x:javadoc href="Channel.html#confirmSelect()"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_ConfirmSelect"/>
    </x:decorate>
    <x:decorate target="method" name="exchange.bind">
      <x:amqp-extension />
      <x:url href="http://www.rabbitmq.com/e2e.html" label="RabbitMQ Documentation"/>
      <x:url href="http://www.rabbitmq.com/blog/2010/10/19/exchange-to-exchange-bindings/" label="RabbitMQ blog post"/>
      <x:javadoc href="Channel.html#exchangeBind(java.lang.String, java.lang.String, java.lang.String, java.util.Map)"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_ExchangeBind_System_String_System_String_System_String_System_Collections_Generic_IDictionary_System_String_System_Object__"/>
    </x:decorate>
    <x:decorate target="method" name="exchange.declare">
      <x:field override="auto-delete" name="auto-delete" domain="bit"/>
      <x:field override="internal" name="internal" domain="bit"/>
      <x:doc>
        <p>
          RabbitMQ implements an extension to the AMQP 0-9-1 specification that allows for unroutable messages
          to be delivered to an <em>Alternate Exchange</em> (AE). The AE feature helps to detect when clients
          are publishing messages that cannot be routed and can provide "or else" routing semantics where
          some messages are handled specifically and the remainder are processed by a generic handler.
        </p>
      </x:doc>
      <x:url href="http://www.rabbitmq.com/ae.html" label="AE documentation" />
      <x:javadoc href="Channel.html#exchangeDeclare(java.lang.String, java.lang.String, boolean, boolean, java.util.Map)" />
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_ExchangeDeclare_System_String_System_String_System_Boolean_System_Boolean_System_Collections_Generic_IDictionary_System_String_System_Object__" />
    </x:decorate>
    <x:decorate target="method" name="exchange.delete">
      <x:javadoc href="Channel.html#exchangeDelete(java.lang.String, boolean)" />
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_ExchangeDelete_System_String_System_Boolean_" />
    </x:decorate>
    <x:decorate target="method" name="exchange.unbind">
      <x:amqp-extension />
      <x:javadoc href="Channel.html#exchangeUnbind(java.lang.String, java.lang.String, java.lang.String, java.util.Map)"/>
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_ExchangeUnbind_System_String_System_String_System_String_System_Collections_Generic_IDictionary_System_String_System_Object__"/>
    </x:decorate>
    <x:decorate target="method" name="queue.bind">
      <x:javadoc href="Channel.html#queueBind(java.lang.String, java.lang.String, java.lang.String, java.util.Map)" />
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_QueueBind_System_String_System_String_System_String_System_Collections_Generic_IDictionary_System_String_System_Object__" />
    </x:decorate>
    <x:decorate target="method" name="queue.declare">
      <x:doc>
        <p>
          RabbitMQ implements extensions to the AMQP 0-9-1 specification that permits the creator of
          a queue to control various aspects of its behaviour.
        </p>
        <h5>Per-Queue Message TTL</h5>
        <p>
          This extension determines for how long a message published to a queue can live before it is
          discarded by the server. The time-to-live is configured with the <em>x-message-ttl</em>
          argument to the arguments parameter of this method.
        </p>
        <h5>Queue Expiry</h5>
        <p>
          Queues can be declared with an optional lease time. The lease time determines how long a queue
          can remain unused before it is automatically deleted by the server. The lease time is provided
          as an <em>x-expires</em> argument in the arguments parameter to this method.
        </p>
      </x:doc>
      <x:url href="http://www.rabbitmq.com/ttl.html#per-queue-message-ttl" label="x-message-ttl documentation"/>
      <x:url href="http://www.rabbitmq.com/ttl.html#queue-ttl" label="x-expires documentation"/>
      <x:javadoc href="Channel.html#queueDeclare(java.lang.String, boolean, boolean, boolean, java.util.Map)" />
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_QueueDeclare_System_String_System_Boolean_System_Boolean_System_Boolean_System_Collections_Generic_IDictionary_System_String_System_Object__" />
    </x:decorate>
    <x:decorate target="method" name="queue.delete">
      <x:javadoc href="Channel.html#queueDelete(java.lang.String, boolean, boolean)" />
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_QueueDelete_System_String_System_Boolean_System_Boolean_" />
    </x:decorate>
    <x:decorate target="method" name="queue.purge">
      <x:javadoc href="Channel.html#queuePurge(java.lang.String)" />
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_QueuePurge_System_String_" />
    </x:decorate>
    <x:decorate target="method" name="queue.unbind">
      <x:javadoc href="Channel.html#queueUnbind(java.lang.String, java.lang.String, java.lang.String, java.util.Map)" />
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_QueueUnbind_System_String_System_String_System_String_System_Collections_Generic_IDictionary_System_String_System_Object__" />
    </x:decorate>
    <x:decorate target="method" name="tx.commit">
      <x:javadoc href="Channel.html#txCommit()" />
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_TxCommit" />
    </x:decorate>
    <x:decorate target="method" name="tx.rollback">
      <x:javadoc href="Channel.html#txRollback()" />
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_TxRollback" />
    </x:decorate>
    <x:decorate target="method" name="tx.select">
      <x:javadoc href="Channel.html#txSelect()" />
      <x:dotnetdoc href="RabbitMQ.Client.IModel.html#RabbitMQ_Client_IModel_TxSelect" />
    </x:decorate>
  </x:decorations>

</xsl:stylesheet>
